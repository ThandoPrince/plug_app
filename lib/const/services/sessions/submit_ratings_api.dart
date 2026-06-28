import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RatingApiHelper {
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
  // SUBMIT RATING (NO RETRY - MUTATION SAFE)
  // =========================
  static Future<bool> submitRating({
    required int sessionId,
    required String clientEmail,
    required int rating,
    String? comment,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/$sessionId/rate-provider/$clientEmail/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .patch(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
                'score': rating,
                'review': comment ?? '',
              }),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      // =========================
      // DEBUG LOGGING
      // =========================
      if (kDebugMode) {
        print("========== RATING SUBMIT ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("===================================");
      }

      // =========================
      // SUCCESS CASES
      // =========================
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      // =========================
      // FAILURE CASE
      // =========================
      throw Exception("Server error (${response.statusCode}).");

    } catch (e) {
      throw _handleError(e);
    }
  }
}