import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientPendingOrderDetailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<OrderServiceModel> fetchBookingByOrderID(
    int orderID,
  ) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/$orderID');

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
        debugPrint("========== ORDER DETAIL API ==========");
        debugPrint("URL: $url");
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");
        debugPrint("=====================================");
      }

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception("Invalid order detail format");
        }

        return OrderServiceModel.fromJson(decoded);
      }

      // =========================
      // NOT FOUND
      // =========================
      if (response.statusCode == 404) {
        throw Exception("Order not found");
      }

      // =========================
      // AUTH ERROR
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Unauthorized access to order");
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
      throw Exception("Order detail request timed out");
    } on FormatException {
      throw Exception("Invalid JSON in order detail response");
    } catch (e) {
      throw Exception("ClientPendingOrderDetailApi error: $e");
    }
  }
}