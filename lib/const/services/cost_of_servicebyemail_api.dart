import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CostOfServiceByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch cost of service for a single provider email
  static Future<List<CostOfServiceModel>> fetchCostOfServiceByEmail(String email) async {
    final url = Uri.parse('$baseUrl/cost_of_service/$email/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CostOfServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load service provider cost list for $email');
    }
  }

  /// Fetch cost of service for multiple provider emails
  static Future<List<CostOfServiceModel>> fetchCostsByEmails(List<String> emails) async {
    List<CostOfServiceModel> allCosts = [];

    for (final email in emails) {
      try {
        final costs = await fetchCostOfServiceByEmail(email);
        allCosts.addAll(costs);
      } catch (e) {
        // Log error and continue fetching other emails
        print('Failed to fetch costs for $email: $e');
      }
    }

    return allCosts;
  }
}
