import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../const/services/api_tokens_helper.dart';

class CancelOrderApiHelper {
  Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
  }) async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      final response = await http.post(
        Uri.parse(
          '$baseUrl/bookings/cancel_order/',
        ),
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode({
          "order_id": orderId,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": body["message"],
        };
      }

      return {
        "success": false,
        "message":
            body["message"] ??
            "Failed to cancel order.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}