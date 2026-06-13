import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/services_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH SERVICES
  // =========================
  static Future<List<ServiceModel>> fetchServices() async {
    final url = Uri.parse('$baseUrl/services/');

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(), // safe even if token null
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
        print('Services Response: ${response.body}');
      }

      if (decoded is! List) {
        throw Exception('Invalid services response format');
      }

      return decoded.map((item) => ServiceModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('ServiceApi.fetchServices error: $e');
    }
  }
}
