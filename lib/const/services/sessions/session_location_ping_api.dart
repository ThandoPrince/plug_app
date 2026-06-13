import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/session_location_ping_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ClientSessionLocationPingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH LATEST LOCATION PING
  // =========================
  static Future<ClientSessionLocationPingModel?> fetchLatestPing(
    int sessionId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/sessions/$sessionId/latest-ping/',
    );

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
      // SAFE JSON PARSE
      // =========================
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid ping response format');
      }

      if (decoded.isEmpty) return null;

      return ClientSessionLocationPingModel.fromJson(decoded);
    } catch (e) {
      if (kDebugMode) {
        print('ClientSessionLocationPingApi error: $e');
      }
      throw Exception('Failed to fetch latest session ping: $e');
    }
  }
}
