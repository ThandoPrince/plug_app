import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:http/http.dart' as http;

class ShipmentConfirmApi {
  final String baseUrl;

  ShipmentConfirmApi({required this.baseUrl});

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // ERROR HANDLER
  // =========================
  Exception _handleError(Object e) {
    if (e is TimeoutException) {
      return Exception("Server timeout. Please try again.");
    }

    if (e is SocketException) {
      return Exception("Server unreachable. Check your internet connection.");
    }

    return Exception("Unexpected error occurred.");
  }

  // =========================
  // CONFIRM SHIPMENT (POST - NO RETRY)
  // =========================
  Future<Map<String, dynamic>> confirmShipment(int shipmentId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/shipment/$shipmentId/confirm/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== CONFIRM SHIPMENT ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("======================================");
      }

      // Accept both 200 and 201 (common REST behavior)
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response format.");
      }

      return decoded;

    } catch (e) {
      throw _handleError(e);
    }
  }
}