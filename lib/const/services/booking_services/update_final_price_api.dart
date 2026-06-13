import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class PatchOrderFinalPriceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

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
      if (isNegotiated != null) 'is_negotiated': isNegotiated,
    };

    try {
      final response = await http.patch(
        url,
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print("Patch Final Price HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw Exception('Unexpected success response format');
      }

      // Unified error handling
      if (decoded is Map<String, dynamic>) {
        throw Exception(decoded.toString());
      }

      throw Exception(
        'Failed to update final price: ${response.body}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('PatchOrderFinalPriceApi error: $e');
      }
      throw Exception('Error updating final price: $e');
    }
  }
}
