import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/sp_live_location_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class SpAddByServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH SPs BY SERVICE ID
  // =========================
  static Future<List<SPLiveLocationModel>> fetchSPsByAddress(
    int serviceId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/service_providersDB/live-loc-by-service/$serviceId/',
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

      if (decoded is! List) {
        throw Exception('Invalid response format (expected List)');
      }

      return decoded
          .map(
            (item) => SPLiveLocationModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('SpAddByServiceApi error: $e');
    }
  }
}
