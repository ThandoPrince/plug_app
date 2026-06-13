import 'dart:convert';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentApi {
  ShipmentApi._();
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch shipments by client email (newest first)
  static Future<List<Shipment>> getShipmentsByClientEmail(
    String clientEmail,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_shipment/by_client_email/$clientEmail/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
