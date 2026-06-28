import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:http/http.dart' as http;

class ServiceProviderByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH PROVIDER BY ID
  // =========================
  static Future<ServiceProviderModel> fetchProviderByEmail(int id) async {
    final url = Uri.parse('$baseUrl/service_providers/$id/');

    final response = await ApiClient.instance.request((token) {
      return http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (kDebugMode) {
        print(response.body);
        print(data.runtimeType);
      }

      if (data is List) {
        if (data.isEmpty) {
          throw Exception('Provider not found');
        }

        return ServiceProviderModel.fromJson(
          data.first as Map<String, dynamic>,
        );
      }

      if (data is Map<String, dynamic>) {
        return ServiceProviderModel.fromJson(data);
      }

      throw Exception('Unexpected response format');
    }

    throw Exception(
      'Failed to load service provider: '
      '${response.statusCode} ${response.body}',
    );
  }
}