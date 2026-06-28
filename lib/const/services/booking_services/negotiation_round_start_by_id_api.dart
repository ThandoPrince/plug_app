import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NegotiatiationRoundStartApi {
  static final String coreUrl = dotenv.env['API_BASE_URL'] ?? '';

  static final String baseUrl =
      "$coreUrl/bookings/service_orders/negotiation/rounds";

  static Future<bool> startClientRound({
    required int negotiationId,
    required double offeredPrice,
    String? message,
  }) async {
    final url = Uri.parse(
      "$baseUrl/$negotiationId/client_start_round/",
    );

    try {
      final response = await ApiClient.instance.request((token) {
        return http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
                "offered_price": offeredPrice,
                "message": message ?? "",
              }),
            )
            .timeout(const Duration(seconds: 12));
      });

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 201) {
        return true;
      }

      // =========================
      // AUTH FAILURE
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint("AUTH FAILURE: ${response.statusCode} → ${response.body}");
        return false;
      }

      // =========================
      // CLIENT ERROR (BAD PAYLOAD, VALIDATION)
      // =========================
      if (response.statusCode >= 400 && response.statusCode < 500) {
        debugPrint("CLIENT ERROR: ${response.statusCode} → ${response.body}");
        return false;
      }

      // =========================
      // SERVER ERROR
      // =========================
      if (response.statusCode >= 500) {
        debugPrint("SERVER ERROR: ${response.statusCode} → ${response.body}");
        return false;
      }

      return false;
    } on TimeoutException {
      debugPrint("TIMEOUT ERROR: negotiation round request timed out");
      return false;
    } on FormatException {
      debugPrint("FORMAT ERROR: invalid JSON response");
      return false;
    } catch (e) {
      debugPrint("NETWORK ERROR: $e");
      return false;
    }
  }
}