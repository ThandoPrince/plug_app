import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_application_1/global_util/services/models/client_models/login_reponse_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';


class AuthLoginApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // LOGIN (STEP 1: password check)
  // =========================
  // CHANGED: this now only verifies identifier+password and returns a
  // verification_token that must be exchanged for real session tokens via
  // LoginOtpApi.verifyLoginOtp(). It no longer returns access/refresh tokens.
  Future<LoginChallengeResponse> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/clientsDB/login/');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "identifier": identifier.toLowerCase().trim(),
              "password": password,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
  final challenge =
      LoginChallengeResponse.fromJson(data);

  await AuthSessionController.instance
      .updateVerificationToken(
    challenge.data.verificationToken,
    otpRequestId: challenge.data.otpRequestId,
  );

  return challenge;
}

      throw ApiException(
        statusCode: response.statusCode,
        data: data,
      );
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        data: {"error": "Server timeout"},
      );
    } on SocketException {
      throw ApiException(
        statusCode: 503,
        data: {"error": "Server unreachable"},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        data: {"error": "Unexpected error: $e"},
      );
    }
  }

  // =========================
  // PUSH TOKEN REGISTER
  // =========================
  Future<Map<String, dynamic>> updatePushToken({
    required String token,
    required String provider,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final authToken = AuthSessionController.instance.accessToken;

    final uri = Uri.parse(
      '$baseUrl/client_devices/register-device-token/',
    );

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              "push_token": token,
              "device_type": deviceType,
              "device_name": deviceName,
              "os_version": osVersion,
              "app_version": appVersion,
              "provider": provider,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "error": "Failed to update push token: $e",
        },
      };
    }
  }
}

// =========================
// CENTRALIZED EXCEPTION TYPE
// =========================
class ApiException implements Exception {
  final int statusCode;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.data,
  });
}