import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';

class NegotiationByIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<NegotiationModel?> fetchNegotiationById(int negotiationId) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/negotiation/$negotiationId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NegotiationModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch negotiation by ID (${response.statusCode})");
    }
  }
}
