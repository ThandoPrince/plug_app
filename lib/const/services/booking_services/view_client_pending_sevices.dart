import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientPendingOrdersApi {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';



  /// Fetch pending orders for a client by email
  Future<List<OrderServiceModel>> fetchPendingOrdersByClientEmail(String email) async {
    final url = Uri.parse('$_baseUrl/bookings/client_active_orders/$email/');


    final response = await http.get(url);
      if (kDebugMode) {
        print("Requesting: $url");
      }
  if (kDebugMode) {
    print("Status: ${response.statusCode}");
  }
  if (kDebugMode) {
    print("Response body: ${response.body}");
  }

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pending orders: ${response.body}');
    }
  }
}
