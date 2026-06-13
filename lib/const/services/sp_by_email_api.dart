import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

class ServiceProviderByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // CENTRALIZED HEADERS
  // =========================
  static Map<String, String> _headers() {
    final token = AuthSessionController.instance.accessToken;

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // =========================
  // FETCH PROVIDER BY EMAIL
  // =========================
  static Future<ServiceProviderModel> fetchProviderByEmail(
    int id,
  ) async {
    final url = Uri.parse('$baseUrl/service_providers/$id/');

    try {
      final response = await http.get(
        url,
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProviderModel.fromJson(data);
      }

      throw Exception(
        'Failed to load service provider: '
        '${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Error fetching service provider: $e');
    }
  }
}