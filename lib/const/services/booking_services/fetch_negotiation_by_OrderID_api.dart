import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NegotiationByOrderidApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch all negotiations by a given Order ID
  static Future<List<NegotiationModel>> fetchNegotiationByOrderID(int orderID) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/negotiation/by-order/$orderID');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NegotiationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load negotiation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching the negotiation: $e');
    }
  }

  /// Fetch all negotiations (global list)
  static Future<List<NegotiationModel>> fetchAllNegotiations(int orderID) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/negotiation/by-order/$orderID');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NegotiationModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load the negotiation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching the negotiation: $e');
    }
  }
}
