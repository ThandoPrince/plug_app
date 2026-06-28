import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentCancelApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<bool> cancelShipment({
    required int shipmentId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/shipment/$shipmentId/cancel/',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http
            .patch(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(const Duration(seconds: 12)),
      );

      if (kDebugMode) {
        debugPrint("========== CANCEL SHIPMENT ==========");
        debugPrint("URL: $url");
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");
        debugPrint("====================================");
      }

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      // =========================
      // AUTH ERROR
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Unauthorized request to cancel shipment");
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
        "Unexpected response ${response.statusCode}: ${response.body}",
      );
    } on TimeoutException {
      throw Exception("Cancel shipment request timed out");
    } on FormatException {
      throw Exception("Invalid response format");
    } catch (e) {
      if (kDebugMode) {
        debugPrint("CancelShipment API Error: $e");
      }
      return false;
    }
  }
}