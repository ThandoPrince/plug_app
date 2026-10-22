import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientPendingOrdersApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  /// Fetch pending orders for the authenticated client
  Future<List<OrderServiceModel>> fetchPendingOrdersByClientEmail() async {
    final clientId = AuthSessionController.instance.clientId;

    final url = Uri.parse(
      '$_baseUrl/bookings/client_active_orders/$clientId/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== CLIENT PENDING ORDERS ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("===========================================");
      }

      // No pending orders
      if (response.statusCode == 404) {
        return [];
      }

      // Any other unsuccessful response
      if (response.statusCode != 200) {
        throw Exception(
          "Failed to load pending orders. Please try again.",
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          "Unable to load pending orders. Please try again.",
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(OrderServiceModel.fromJson)
          .toList();
    } on TimeoutException {
      throw Exception(
        "Server timeout. Please try again.",
      );
    } on SocketException {
      throw Exception(
        "Server unreachable. Check your internet connection.",
      );
    } on FormatException {
      throw Exception(
        "Unable to process the server response. Please try again.",
      );
    } catch (e) {
      // Log the actual exception for developers,
      // but NEVER expose it to the client.
      if (kDebugMode) {
        print("ClientPendingOrdersApi error: $e");
      }

      throw Exception(
        "Unable to load pending orders. Please try again.",
      );
    }
  }
}