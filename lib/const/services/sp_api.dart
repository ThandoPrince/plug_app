import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ServiceProviderApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<ServiceProviderModel>> fetchAllServiceProviders(
    int serviceId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/service_providers/?service_id=$serviceId',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      // =========================
      // STATUS CHECK FIRST
      // =========================
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      // =========================
      // SAFE JSON PARSE
      // =========================
      final decoded = jsonDecode(response.body);

      if (kDebugMode) {
        print('Service Providers Response: ${response.body}');
      }

      if (decoded is! List) {
        throw Exception('Invalid response format (expected List)');
      }

      return decoded
          .map((item) => ServiceProviderModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('ServiceProviderApi error: $e');
    }
  }
}
