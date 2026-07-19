import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentApi {
  ShipmentApi._();

  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<Shipment>> getShipmentsByClientEmail() async {
    final clientId = AuthSessionController.instance.clientId;

    final url = Uri.parse(
      '$baseUrl/bookings/get_shipment/by_client_email/$clientId/',
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
            .timeout(const Duration(seconds: 15)),
      );

      if (kDebugMode) {
        debugPrint("========== SHIPMENT API ==========");
        debugPrint("URL: $url");
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");
        debugPrint("==================================");
      }

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception("Invalid response format (expected Map)");
        }

        final data = decoded['data'];

        if (data is! List) return [];

        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => Shipment.fromJson(item))
            .toList();
      }

      // =========================
      // EMPTY
      // =========================
      if (response.statusCode == 204) {
        return [];
      }

      // =========================
      // AUTH
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Unauthorized access to shipments");
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
      throw Exception("Shipment request timed out");
    } on FormatException {
      throw Exception("Invalid JSON format in shipment response");
    } catch (e) {
  if (e is TimeoutException) {
    throw Exception("Request timed out. Check your connection.");
  }

  final msg = e.toString().toLowerCase();

  if (msg.contains("socketexception") ||
      msg.contains("failed host lookup") ||
      msg.contains("unreachable") ||
      msg.contains("network is unreachable")) {
    throw Exception("No internet connection. Please try again.");
  }

  throw Exception("Unable to load shipments.");
}
  }
}