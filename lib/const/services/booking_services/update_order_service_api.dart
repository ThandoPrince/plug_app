import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UpdateOrderServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> updateOrder({
    required int orderId,
    String? title,
    String? notes,
    String? requestedDate,
    String? requestedTime,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/service_orders/$orderId/update/',
    );

    final Map<String, dynamic> body = {};

    if (title != null) body["title"] = title;
    if (notes != null) body["notes"] = notes;
    if (requestedDate != null) {
      body["requested_date"] = requestedDate;
    }
    if (requestedTime != null) {
      body["requested_date_time"] = requestedTime;
    }

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
        print("========== UPDATE ORDER ==========");
        print("URL: $url");
        print("BODY: ${jsonEncode(body)}");
        print("STATUS: ${response.statusCode}");
        print("RESPONSE: ${response.body}");
        print("==================================");
      }

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        if (decoded is! Map<String, dynamic>) {
          throw Exception("Invalid update response.");
        }

        return decoded;
      }

      throw Exception(_extractError(decoded, response.statusCode));
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
  static String _extractError(
    dynamic decoded,
    int statusCode,
  ) {
    if (decoded is Map<String, dynamic>) {
      return decoded["message"] ??
          decoded["error"] ??
          decoded["detail"] ??
          "Failed to update order.";
    }

    return "Failed to update order ($statusCode).";
  }
}