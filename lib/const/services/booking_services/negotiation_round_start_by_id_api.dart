import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NegotiatiationRoundStartApi {
  static final String coreUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static final String baseUrl =
      "$coreUrl/bookings/service_orders/negotiation/rounds";

  static Future<bool> startClientRound({
    required int negotiationId,
    required double offeredPrice,
    String? message,
  }) async {
    final url = Uri.parse(
      "$baseUrl/$negotiationId/client_start_round/",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "offered_price": offeredPrice,
        "message": message ?? "",
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
        "❌ Failed: ${response.statusCode} → ${response.body}",
      );
      return false;
    }
  }
}

