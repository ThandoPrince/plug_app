import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CancelOrderApiHelper {
  Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final url = Uri.parse('$baseUrl/bookings/cancel_order/');

    try {
      final response = await ApiClient.instance.request(
        (token) => http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
                "order_id": orderId,
              }),
            )
            .timeout(const Duration(seconds: 12)),
      );

      if (kDebugMode) {
        debugPrint("========== CANCEL ORDER API ==========");
        debugPrint("URL: $url");
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");
        debugPrint("======================================");
      }

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        return {
          "success": true,
          "message": body["message"] ?? "Order cancelled successfully",
        };
      }

      // =========================
      // AUTH ERROR
      // =========================
      if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          "success": false,
          "message": "Unauthorized request",
        };
      }

      // =========================
      // CLIENT ERROR
      // =========================
      if (response.statusCode >= 400 && response.statusCode < 500) {
        final body = _safeDecode(response.body);

        return {
          "success": false,
          "message": body["message"] ?? "Client error occurred",
        };
      }

      // =========================
      // SERVER ERROR
      // =========================
      if (response.statusCode >= 500) {
        return {
          "success": false,
          "message": "Server error. Please try again later.",
        };
      }

      return {
        "success": false,
        "message":
            "Unexpected response ${response.statusCode}: ${response.body}",
      };
    } on TimeoutException {
      return {
        "success": false,
        "message": "Request timed out. Please try again.",
      };
    } on FormatException {
      return {
        "success": false,
        "message": "Invalid response format from server.",
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint("CancelOrder API Error: $e");
      }

      return {
        "success": false,
        "message": "Cancel order failed: $e",
      };
    }
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}