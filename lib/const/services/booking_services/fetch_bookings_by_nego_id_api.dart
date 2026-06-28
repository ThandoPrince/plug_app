import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NegotiationByIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<NegotiationModel?> fetchNegotiationById(
    int negotiationId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/service_orders/negotiation/$negotiationId',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http
            .get(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(const Duration(seconds: 12)),
      );

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception("Invalid negotiation response format");
        }

        return NegotiationModel.fromJson(data);
      }

      // =========================
      // NOT FOUND (valid state)
      // =========================
      if (response.statusCode == 404) {
        return null;
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