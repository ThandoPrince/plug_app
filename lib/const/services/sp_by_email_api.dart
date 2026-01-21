import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class ServiceProviderByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<ServiceProviderModel> fetchProviderByEmail(String email) async {
    final url = Uri.parse('$baseUrl/service_providers/$email/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ServiceProviderModel.fromJson(data);
    } else {
      throw Exception('Failed to load service provider');
    }
  }
}
