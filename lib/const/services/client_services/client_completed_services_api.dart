import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientCompletedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // FETCH CLIENT COMPLETED SERVICES (RATINGS)
  // =========================
  static Future<List<RatingModel>> fetchRatingsByClient() async {
    final clientId = AuthSessionController.instance.clientId;

    final url = Uri.parse(
      '$baseUrl/bookings/get_ratings/by_client_email/$clientId/',
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
        print("========== CLIENT RATINGS API ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("========================================");
      }

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception("Invalid ratings response format.");
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(RatingModel.fromJson)
          .toList();
    } on TimeoutException {
      throw Exception(
        "Server timeout. Please try again.",
      );
    } on SocketException {
      throw Exception(
        "Server unreachable. Check your internet connection.",
      );
    }
  }

  // =========================
  // ERROR PARSER
  // =========================
  static String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded["message"] ??
            decoded["error"] ??
            decoded["detail"] ??
            "Failed to fetch client ratings.";
      }
    } catch (_) {}

    return "Failed to fetch client ratings (${response.statusCode}).";
  }
}