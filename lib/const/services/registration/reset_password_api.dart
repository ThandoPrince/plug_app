// reset_password_api.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/client_models/password_reset_challenge_model.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart' show ApiException;

class ResetPasswordApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // STEP 1: request password reset OTP
  // =========================
  static Future<PasswordResetChallengeResponse> requestOtp({
    String? email,
    String? mobileNumber,
  }) async {
    final url = Uri.parse('$baseUrl/client/login/password-reset-otp/');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              if (email != null && email.trim().isNotEmpty)
                'email': email.trim().toLowerCase(),
              if (mobileNumber != null && mobileNumber.trim().isNotEmpty)
                'mobile_number': mobileNumber.trim(),
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PasswordResetChallengeResponse.fromJson(data);
      }

      throw ApiException(statusCode: response.statusCode, data: data);
    } on TimeoutException {
      throw ApiException(statusCode: 408, data: {"error": "Server timeout"});
    } on SocketException {
      throw ApiException(statusCode: 503, data: {"error": "Server unreachable"});
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 500, data: {"error": "Unexpected error: $e"});
    }
  }


static Future<Map<String, dynamic>> confirmReset({
  required String otp,
  required String newPassword,
  required String verificationToken,
}) async {
  final url = Uri.parse('$baseUrl/client/reset-password/');

  try {
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $verificationToken',
          },
          body: jsonEncode({
            'otp': otp,
            'new_password': newPassword,
          }),
        )
        .timeout(_timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message'] ?? 'Password reset successfully'};
    }

    throw ApiException(statusCode: response.statusCode, data: data);
  } on TimeoutException {
    throw ApiException(statusCode: 408, data: {"error": "Server timeout"});
  } on SocketException {
    throw ApiException(statusCode: 503, data: {"error": "Server unreachable"});
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(statusCode: 500, data: {"error": "Unexpected error: $e"});
  }
}
}