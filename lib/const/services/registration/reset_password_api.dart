import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ResetPasswordApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // RESET PASSWORD
  // =========================
  static Future<Map<String, dynamic>> resetPassword({
    String? email,
    String? mobileNumber,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/client/reset-password/');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              if (email != null && email.trim().isNotEmpty)
                'email': email.trim(),

              if (mobileNumber != null && mobileNumber.trim().isNotEmpty)
                'mobile_number': mobileNumber.trim(),

              'new_password': newPassword,
            }),
          )
          .timeout(_timeout);

      // =========================
      // DEBUG LOGGING
      // =========================
      print("========== RESET PASSWORD ==========");
      print("URL: $url");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("====================================");

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      // =========================
      // SUCCESS CASE
      // =========================
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully',
        };
      }

      // =========================
      // FAILURE CASE (CONTROLLED)
      // =========================
      return {
        'success': false,
        'message': _extractError(data),
      };

    } on SocketException {
      return {
        'success': false,
        'message': 'Server unreachable. Check your internet connection.',
      };

    } on TimeoutException {
      return {
        'success': false,
        'message': 'Server timeout. Please try again.',
      };

    } catch (_) {
      return {
        'success': false,
        'message': 'Unexpected error occurred.',
      };
    }
  }

  // =========================
  // SAFE ERROR EXTRACTION
  // =========================
  static String _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          'Failed to reset password';
    }
    return 'Failed to reset password';
  }
}