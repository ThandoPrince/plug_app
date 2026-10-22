import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';

class NegotiationByOrderidApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<NegotiationModel>> fetchNegotiationByOrderID(
    int orderID,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/service_orders/negotiation/by-order/$orderID/',
    );

    try {
      final response = await ApiClient.instance.request((token) {
        return http
            .get(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(const Duration(seconds: 60));
      });

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw Exception("Invalid response format (expected List)");
        }

        if (kDebugMode) {
          debugPrint("Negotiations loaded successfully: ${decoded.length}");
        }

        return decoded
            .whereType<Map<String, dynamic>>()
            .map((json) => NegotiationModel.fromJson(json))
            .toList();
      }

      // =========================
      // EMPTY STATE
      // =========================
      if (response.statusCode == 204) {
        return [];
      }

      // =========================
      // AUTH FAILURE
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Unauthorized access: ${response.body}");
      }

      // =========================
      // CLIENT ERROR
      // =========================
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
          "Client error ${response.statusCode}: ${response.body}",
        );
      }

      // =========================
      // SERVER ERROR
      // =========================
      if (response.statusCode >= 500) {
        throw Exception(
          "Server error ${response.statusCode}: ${response.body}",
        );
      }

      throw Exception(
        "Unexpected response: ${response.statusCode} ${response.body}",
      );
    } on TimeoutException {
      throw Exception("Request timed out. Please try again.");
    } on FormatException {
      throw Exception("Invalid JSON response from server.");
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}