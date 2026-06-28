import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PatchOrderFinalPriceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // PATCH FINAL PRICE
  // =========================
  static Future<Map<String, dynamic>> patchFinalPrice({
    required int orderId,
    required double finalPrice,
    bool? isNegotiated,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/$orderId/final-price/',
    );

    final body = <String, dynamic>{
      'final_price': finalPrice,
      if (isNegotiated != null)
        'is_negotiated': isNegotiated,
    };

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
        print("========== PATCH FINAL PRICE ==========");
        print("URL: $url");
        print("BODY: ${jsonEncode(body)}");
        print("STATUS: ${response.statusCode}");
        print("RESPONSE: ${response.body}");
        print("=======================================");
      }

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        if (decoded is! Map<String, dynamic>) {
          throw Exception(
            "Invalid response format.",
          );
        }

        return decoded;
      }

      throw Exception(
        _extractError(decoded, response.statusCode),
      );
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
          "Failed to update final price.";
    }

    return "Failed to update final price ($statusCode).";
  }
}