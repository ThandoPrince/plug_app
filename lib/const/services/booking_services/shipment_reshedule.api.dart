import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentRescheduleApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 10);

  Future<bool> rescheduleShipment({
    required int shipmentId,
    required String newDate,
    required String newTime,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/shipment/$shipmentId/reschedule/',
    );

    final body = {
      "shipment_schedule_date": newDate,
      "shipment_schedule_time": newTime,
    };

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
              body: jsonEncode(body),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== RESCHEDULE SHIPMENT ==========");
        print("URL: $url");
        print("BODY: ${jsonEncode(body)}");
        print("STATUS: ${response.statusCode}");
        print("RESPONSE: ${response.body}");
        print("=========================================");
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      _throwApiError(response);
    } on TimeoutException {
      if (kDebugMode) {
        print("Shipment reschedule timeout");
      }
      throw Exception("Server timeout. Please try again.");
    } on SocketException {
      if (kDebugMode) {
        print("Shipment reschedule network error");
      }
      throw Exception("Server unreachable. Check your internet connection.");
    }

    return false; // unreachable but keeps analyzer happy
  }

  // =========================
  // ERROR HANDLER
  // =========================
  static Never _throwApiError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded["message"] ??
              decoded["error"] ??
              decoded["detail"] ??
              "Failed to reschedule shipment.",
        );
      }
    } catch (_) {}

    throw Exception(
      "Failed to reschedule shipment (${response.statusCode}).",
    );
  }
}