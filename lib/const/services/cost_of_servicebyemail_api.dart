import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class CostOfServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // SINGLE PROVIDER + SERVICE
  // =========================
  static Future<CostOfServiceModel?> fetchCostByEmailAndService(
    int providerId,
    int serviceId,
  ) async {
    final url = Uri.parse('$baseUrl/cost_of_service/$providerId/$serviceId/');

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      // =========================
      // STATUS HANDLING
      // =========================
      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      // =========================
      // SAFE PARSE
      // =========================
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid cost response format');
      }

      return CostOfServiceModel.fromJson(decoded);
    } catch (e) {
      throw Exception(
        'CostOfServiceApi.fetchCostByEmailAndService error: $e',
      );
    }
  }

  // =========================
  // MULTIPLE PROVIDERS (OPTIMIZED)
  // =========================
  static Future<List<CostOfServiceModel>> fetchCostsByEmailsAndService(
    List<int> providerIds,
    int serviceId,
  ) async {
    try {
      // 🚀 PARALLEL REQUESTS (FASTER THAN LOOP)
      final futures = providerIds.map(
        (providerId) => fetchCostByEmailAndService(providerId, serviceId),
      );

      final results = await Future.wait(futures);

      return results.whereType<CostOfServiceModel>().toList();
    } catch (e) {
      if (kDebugMode) {
        print('Batch cost fetch error: $e');
      }
      return [];
    }
  }
}
