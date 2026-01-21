import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ShipmentConfirmApi {
  final String baseUrl;

  ShipmentConfirmApi({required this.baseUrl});

  /// Confirm shipment by ID
  Future<Map<String, dynamic>> confirmShipment(int shipmentId) async {
    final url = Uri.parse('$baseUrl/bookings/shipment/$shipmentId/confirm/');

    if (kDebugMode) {
      print("POST: $url");
    }

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer YOUR_TOKEN"
      },
    );

    if (kDebugMode) {
      print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to confirm shipment (${response.statusCode}): ${response.body}',
      );
    }
  }
}
