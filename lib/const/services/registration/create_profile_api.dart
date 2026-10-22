import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateProfileApi {
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

    return Exception("Unexpected error occurred.");
  }

  // =========================
  // SAFE PATCH REQUEST
  // =========================
  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .patch(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode(body ?? {}),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      // =========================
      // DEBUG LOGGING
      // =========================
      print("========== CREATE PROFILE PATCH ==========");
      print("URL: $url");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=========================================");

      return response;

    } catch (e) {
      throw _handleError(e);
    }
  }
}