import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ShipmentConfirmApi {
  final String baseUrl;

  ShipmentConfirmApi({required this.baseUrl});

  // =========================
  // CONFIRM SHIPMENT
  // =========================
  Future<Map<String, dynamic>> confirmShipment(int shipmentId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/shipment/$shipmentId/confirm/',
    );

    try {
      if (kDebugMode) {
        print("POST: $url");
      }

      final response = await http.post(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Status: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      // =========================
      // STATUS CHECK FIRST
      // =========================
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      // =========================
      // SAFE JSON PARSE
      // =========================
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return decoded;
    } catch (e) {
      throw Exception('ShipmentConfirmApi error: $e');
    }
  }
}
