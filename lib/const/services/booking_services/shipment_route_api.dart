import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentRouteApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // FETCH ROUTES BY SHIPMENT
  // =========================
  static Future<List<ShipmentRouteModel>> fetchRoutesByShipment(
    int shipmentId,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/bookings/client/shipment/$shipmentId/route/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              uri,
              headers: {
                "Content-Type": "application/json",
                if (token != null)
                  "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== SHIPMENT ROUTES ==========");
        print("URL: $uri");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=====================================");
      }

      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception(
          _extractError(response),
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          "Invalid shipment routes response.",
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ShipmentRouteModel.fromJson)
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
      final response = await ApiClient.instance.request((token) async {
        return await http
            .post(
              uri,
              headers: {
                "Content-Type": "application/json",
                if (token != null)
                  "Authorization": "Bearer $token",
              },
              body: jsonEncode(payload),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== CREATE SHIPMENT ROUTE ==========");
        print("URL: $uri");
        print("PAYLOAD: ${jsonEncode(payload)}");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("===========================================");
      }

      if (response.statusCode != 201) {
        throw Exception(
          _extractError(response),
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          "Invalid route creation response.",
        );
      }

      return ShipmentRouteModel.fromJson(decoded);
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
            "Request failed.";
      }
    } catch (_) {}

    return "Request failed (${response.statusCode}).";
  }
}