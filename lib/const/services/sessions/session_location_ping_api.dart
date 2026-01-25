import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_location_ping_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientSessionLocationPingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch **only the latest location ping** for a session
  static Future<ClientSessionLocationPingModel?> fetchLatestPing(int sessionId) async {
    final url = Uri.parse('$baseUrl/sessions/$sessionId/location-pings/latest/');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['API_TOKEN'] ?? ''}',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body) as Map<String, dynamic>?;
      if (data == null || data.isEmpty) return null;
      return ClientSessionLocationPingModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch latest session ping (${response.statusCode})');
    }
  }
}
