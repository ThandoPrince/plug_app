import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DeleteAccountApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static const Duration _timeout = Duration(seconds: 60);

  /// Returns the decoded success payload on 200.
  /// Throws Exception with a clean message on any failure.
  /// Throws DeleteAccountFieldException when the backend returns
  /// field-keyed validation errors (password/confirmation).
  static Future<Map<String, dynamic>> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    final uri = Uri.parse('$baseUrl/client/delete-account/');

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .post(
              uri,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
                "password": password,
                "confirmation": confirmation,
              }),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("=== DELETE ACCOUNT ===");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
      }

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        if (decoded is! Map<String, dynamic>) {
          throw Exception("Invalid response format.");
        }
        return decoded;
      }

      if (response.statusCode == 400 && decoded is Map<String, dynamic>) {
        // DRF field-error shape: {"password": ["Incorrect password."], ...}
        final fieldErrors = <String, String>{};
        decoded.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value.first.toString();
          } else if (value is String) {
            fieldErrors[key] = value;
          }
        });
        if (fieldErrors.isNotEmpty) {
          throw DeleteAccountFieldException(fieldErrors);
        }
      }

      if (response.statusCode == 409 && decoded is Map<String, dynamic>) {
        throw Exception(decoded["error"]?.toString() ?? "Account cannot be deleted right now.");
      }

      if (response.statusCode == 429) {
        throw Exception("Too many attempts. Please try again later.");
      }

      throw Exception(_extractError(decoded, response.statusCode));
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } on SocketException {
      throw Exception("Server unreachable. Check your internet connection.");
    }
  }

  static String _extractError(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      return decoded["message"] ??
          decoded["error"] ??
          decoded["detail"] ??
          "Failed to delete account.";
    }
    return "Failed to delete account ($statusCode).";
  }
}

/// Carries per-field validation errors (password, confirmation) so the UI
/// can show them next to the relevant field, same pattern as
/// ChangePasswordController.fieldErrors.
class DeleteAccountFieldException implements Exception {
  final Map<String, String> fieldErrors;
  DeleteAccountFieldException(this.fieldErrors);

  @override
  String toString() => fieldErrors.values.join(' ');
}