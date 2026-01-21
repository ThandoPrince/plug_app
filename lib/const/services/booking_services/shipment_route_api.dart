import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class ShipmentRouteApi {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';
  
  static Future<List<ShipmentRouteModel>> fetchRoutesByShipment(
    int shipmentId,
  ) async {
    final uri = Uri.parse('$_baseUrl/bookings/shipment/$shipmentId/route/');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => ShipmentRouteModel.fromJson(e))
          .toList();
           
    }
    

    throw Exception(
      'Failed to load shipment routes (${response.statusCode})',
    );
  }

  
  

  // ---------------------------------
  // POST: Create new route
  // ---------------------------------
  static Future<ShipmentRouteModel> createRoute(
    int shipmentId,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseUrl/shipments/$shipmentId/routes/');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      return ShipmentRouteModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create shipment route (${response.statusCode})',
    );
  }
}
