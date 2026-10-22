import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/client_models/client_register_auth_model.dart';

class ClientAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // ERROR HANDLER
  // =========================
  static Exception _handleError(Object e) {
  if (e is TimeoutException) {
    return Exception("Server timeout. Please try again.");
  }
  if (e is SocketException) {
    return Exception("Server unreachable. Check your internet connection.");
  }
  if (kDebugMode) {
    debugPrint("Unhandled error in ClientAuthApi: $e");
  }
  return Exception("Unexpected error occurred.");
}

  // =========================
  // REGISTER CLIENT
  // =========================
// client_auth_api.dart — register()
static Future<ClientRegisterResponse> register({
  required String email,
  required String mobile,
  required String password,
}) async {
  final url = Uri.parse("$baseUrl/clientsDB/client/register/");

  try {
    final response = await ApiClient.instance.request((token) async {
      return await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email_address": email.toLowerCase(),
              "mobile_number": mobile,
              "password": password,
            }),
          )
          .timeout(_timeout);
    }).timeout(_timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return ClientRegisterResponse.fromJson(data);
    }

    // Structured, not stringified — no JSON round-trip needed downstream.
    throw ApiException(statusCode: response.statusCode, body: data);

  } on ApiException {
    rethrow; // don't let _handleError swallow this into a generic message
  } catch (e) {
    throw _handleError(e);
  }
}

  // =========================
  // UPDATE CLIENT DETAILS (PATCH)
  // =========================
  static Future<http.Response> patchDetails({
    required String email,
    required Map<String, dynamic> data,
  }) async {
    final url =
        Uri.parse("$baseUrl/client/details/update/?email=$email");

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .patch(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode(data),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      return response;

    } catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // PUSH TOKEN UPDATE
  // =========================
  Future<Map<String, dynamic>> updatePushToken({
    required String email,
    required String token,
    required String provider,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/client_devices/register-device-token/',
    );

    try {
      final response = await ApiClient.instance.request((authToken) async {
        return await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                if (authToken != null)
                  'Authorization': 'Bearer $authToken',
              },
              body: jsonEncode({
                "email": email.toLowerCase(),
                "push_token": token,
                "device_type": deviceType,
                "device_name": deviceName,
                "os_version": osVersion,
                "app_version": appVersion,
                "provider": provider,
              }),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      final data = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": data,
      };

    } catch (e) {
      throw _handleError(e);
    }
  }
}

// api_exception.dart
class ApiException implements Exception {
  final int statusCode;
  final Map<String, dynamic> body;

  ApiException({required this.statusCode, required this.body});

  /// Top-level message the backend sent, e.g. "A user with this email already exists."
  String? get message => body['message']?.toString();

  /// Field-level validation errors from DRF serializer.errors, e.g. {"email_address": ["..."]}.
  Map<String, dynamic>? get fieldErrors =>
      body['errors'] is Map<String, dynamic> ? body['errors'] as Map<String, dynamic> : null;
}