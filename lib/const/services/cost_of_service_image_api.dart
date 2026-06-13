import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/cost_of_service_image.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class CostOfServiceImageApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH IMAGES BY COST ID
  // =========================
  static Future<List<CostOfServiceImageModel>> fetchImagesByCostId(
    int costId,
  ) async {
    final url = Uri.parse('$baseUrl/cost_of_service/$costId/images/');

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      // =========================
      // STATUS HANDLING
      // =========================
      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      // =========================
      // SAFE JSON PARSE
      // =========================
      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid image response format');
      }

      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid image item format');
        }

        return CostOfServiceImageModel.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('CostOfServiceImageApi error: $e');
    }
  }
}
