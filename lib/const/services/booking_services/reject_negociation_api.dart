import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RejectNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> rejectNegotiation({
    required int negotiationId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/reject_negotiation/$negotiationId/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .patch(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null)
                  "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print('========== REJECT NEGOTIATION ==========');
        print('URL: $url');
        print('STATUS: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('========================================');
      }

      final decoded = _safeDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": decoded["message"] ?? "Negotiation rejected.",
        };
      }

      return {
        "success": false,
        "message": decoded["message"] ??
            decoded["error"] ??
            "Failed to reject negotiation.",
        "action": decoded["action"],
      };
    } on TimeoutException {
      return {
        "success": false,
        "message": "Server timeout. Please try again.",
      };
    } on SocketException {
      return {
        "success": false,
        "message": "Server unreachable. Check your internet connection.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Unexpected error: $e",
      };
    }
  }

  // =========================
  // SAFE JSON PARSER
  // =========================
  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return {};
  }
}