import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/sp_live_location_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpAddByServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch cost of service for a single provider email
  static Future<List<SPLiveLocationModel>> fetchSPsByAddress(int serviceId) async {
  final url = Uri.parse('$baseUrl/service_providersDB/live-loc-by-service/$serviceId/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => SPLiveLocationModel.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load address for service ID: $serviceId');
  }
}
}
