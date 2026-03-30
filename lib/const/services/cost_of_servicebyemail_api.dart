import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CostOfServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// One provider + one service
  static Future<CostOfServiceModel?> fetchCostByEmailAndService(
    String email,
    int serviceId,
  ) async {
    final url = Uri.parse('$baseUrl/cost_of_service/$email/$serviceId/');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return CostOfServiceModel.fromJson(decoded);
      }

      throw Exception('Unexpected response format.');
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      'Failed to load cost for $email and service $serviceId. '
      'Status: ${response.statusCode}, Body: ${response.body}',
    );
  }

  /// Multiple providers + one service
  static Future<List<CostOfServiceModel>> fetchCostsByEmailsAndService(
    List<String> emails,
    int serviceId,
  ) async {
    final List<CostOfServiceModel> results = [];

    for (final email in emails) {
      try {
        final item = await fetchCostByEmailAndService(email, serviceId);
        if (item != null) {
          results.add(item);
        }
      } catch (e) {
        debugPrint(
          'Failed to fetch cost for provider $email, service $serviceId: $e',
        );
      }
    }

    return results;
  }
}