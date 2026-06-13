import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class RatingApiHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // SUBMIT RATING
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
      final response = await http.patch(
        url,
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode({
          'score': rating,
          'review': comment ?? '',
        }),
      );

      // =========================
      // DEBUG LOGGING
      // =========================
      if (kDebugMode) {
        print('Rating Status: ${response.statusCode}');
        print('Rating Response: ${response.body}');
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
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Rating submission error: $e');
      }
      return false;
    }
  }
}
