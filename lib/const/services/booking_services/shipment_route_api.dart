import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ShipmentRouteApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH ROUTES BY SHIPMENT
  // =========================
  static Future<List<ShipmentRouteModel>> fetchRoutesByShipment(
    int shipmentId,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/bookings/shipment/$shipmentId/route/',
    );

    try {
      final response = await http.get(
        uri,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Shipment Routes HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load shipment routes: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid routes response format');
      }

      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid route item format');
        }
        return ShipmentRouteModel.fromJson(item);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('ShipmentRouteApi error (fetch): $e');
      }
      throw Exception('Error fetching shipment routes: $e');
    }
  }

  // =========================
  // CREATE ROUTE
  // =========================
  static Future<ShipmentRouteModel> createRoute(
    int shipmentId,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/bookings/shipment/$shipmentId/route/create/',
    );

    try {
      final response = await http.post(
        uri,
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print("Create Route HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 201) {
        throw Exception(
          'Failed to create shipment route: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid route creation response format');
      }

      return ShipmentRouteModel.fromJson(decoded);
    } catch (e) {
      if (kDebugMode) {
        print('ShipmentRouteApi error (create): $e');
      }
      throw Exception('Error creating shipment route: $e');
    }
  }
}
