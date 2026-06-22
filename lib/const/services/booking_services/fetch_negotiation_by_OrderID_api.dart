import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NegotiationByOrderidApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<NegotiationModel>> fetchNegotiationByOrderID(
    int orderID,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/service_orders/negotiation/by-order/$orderID',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      // ✅ SUCCESS
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("");
        }
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NegotiationModel.fromJson(json)).toList();
      }

      // ✅ EMPTY STATE (important fix)
      if (response.statusCode == 403) {
        return [];
      }

      // optional: backend "no data" pattern
      if (response.statusCode == 204) {
        return [];
      }

      throw Exception(
        'Failed to load negotiation: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Error fetching negotiation: $e');
    }
  }

  /// (Remove duplicate — it was identical)
  static Future<List<NegotiationModel>> fetchAllNegotiations(
    int orderID,
  ) async {
    return fetchNegotiationByOrderID(orderID);
  }
}
