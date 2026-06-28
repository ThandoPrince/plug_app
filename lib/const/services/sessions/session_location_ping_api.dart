import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/session_location_ping_model.dart';

class ClientSessionLocationPingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 10);

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
  // FETCH LATEST LOCATION PING
  // =========================
  static Future<ClientSessionLocationPingModel?> fetchLatestPing(
    int sessionId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/sessions/$sessionId/latest-ping/',
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

      // =========================
      // DEBUG (safe, structured)
      // =========================
      if (true) {
        print("========== SESSION PING ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("==================================");
      }

      // =========================
      // BUSINESS CASE: NO PING EXISTS
      // =========================
      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid ping response format.");
      }

      if (decoded.isEmpty) {
        return null;
      }

      return ClientSessionLocationPingModel.fromJson(decoded);

    } catch (e) {
      throw _handleError(e);
    }
  }
}