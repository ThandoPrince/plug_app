import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CheckClientRatingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // CHECK IF CLIENT HAS RATED SESSION
  // =========================
  static Future<bool> hasClientRatedSession({
    required String clientEmail,
    required int sessionId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_ratings/by_client_email/$clientEmail/?session_id=$sessionId',
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
        print("========== CLIENT RATING CHECK ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=========================================");
      }

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        return false;
      }

      return decoded.isNotEmpty;

    } catch (e) {
      if (kDebugMode) {
        print("CheckClientRatingApi error: $e");
      }
      return false;
    }
  }
}