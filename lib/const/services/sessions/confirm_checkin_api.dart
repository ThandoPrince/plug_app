import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/session_token_model.dart';

class ClientCheckinApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // ERROR HANDLER
  // =========================
  Exception _handleError(Object e) {
    if (e is TimeoutException) {
      return Exception("Server timeout. Please try again.");
    }

    if (e is SocketException) {
      return Exception("Server unreachable. Check your internet connection.");
    }

    return Exception("Unexpected error occurred.");
  }

  // =========================
  // GET CHECKIN TOKEN (SAFE GET - RETRY ENABLED)
  // =========================
  Future<SessionTokenModel> fetchCheckinToken(int shipmentId) async {
    final url = Uri.parse(
      "$baseUrl/bookings/sessions/get_checkin_token/$shipmentId",
    );

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

      if (kDebugMode) {
        print("========== CHECKIN TOKEN ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("===================================");
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid check-in token format.");
      }

      return SessionTokenModel.fromJson(decoded);

    } catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // CHECK-IN (POST - NO RETRY SAFE)
  // =========================
  Future<Map<String, dynamic>> confirmCheckin({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode(body ?? {}),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== CHECKIN CONFIRM ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=====================================");
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid check-in response format.");
      }

      return decoded;

    } catch (e) {
      throw _handleError(e);
    }
  }
}