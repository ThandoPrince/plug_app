import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/client_models/client_auth.dart';

class ClientAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

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
  // FETCH CLIENT AUTH
  // =========================
  static Future<ClientAuthModel?> fetchClientAuth(String email) async {
    final url = Uri.parse('$baseUrl/client-auth/');

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      // =========================
      // DEBUG LOGGING
      // =========================
      print("========== CLIENT AUTH ==========");
      print("URL: $url");
      print("EMAIL PARAM: $email");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=================================");

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid client auth response format.");
      }

      return ClientAuthModel.fromJson(data);

    } catch (e) {
      throw _handleError(e);
    }
  }
}