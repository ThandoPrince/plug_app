import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;



class ResetPasswordApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static Future<Map<String, dynamic>> resetPassword({
    String? email,
    String? mobileNumber,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/client/reset-password/',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (email != null && email.trim().isNotEmpty)
            'email': email.trim(),

          if (mobileNumber != null &&
              mobileNumber.trim().isNotEmpty)
            'mobile_number': mobileNumber.trim(),

          'new_password': newPassword,
        }),
      );

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message'] ?? 'Password reset successfully',
        };
      }

      return {
        'success': false,
        'message':
            data['error']?.toString() ??
            'Failed to reset password',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server. Please try again.',
      };
    }
  }
}