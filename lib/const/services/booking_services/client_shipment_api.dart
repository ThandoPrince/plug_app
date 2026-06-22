import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentApi {
  ShipmentApi._();
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch shipments by client email (newest first)
  static Future<List<Shipment>> getShipmentsByClientEmail(
    
  ) async {
    final id =  AuthSessionController.instance.clientId;
    final url = Uri.parse(
      '$baseUrl/bookings/get_shipment/by_client_email/$id/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (response.statusCode == 200) {
  final Map<String, dynamic> json = jsonDecode(response.body);

  final List<dynamic> data = json['data'] ?? [];

  return Shipment.listFromJson(data);
} else {
        throw Exception(
          'Failed to load shipments (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('ShipmentApi error: $e');
    }
  }
}
