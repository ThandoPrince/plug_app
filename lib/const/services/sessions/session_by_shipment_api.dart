import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class SessionApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH SESSION BY SHIPMENT
  // =========================
  static Future<SessionModel> getSessionByShipment(
    String shipmentId,
  ) async {
    final url = Uri.parse(
      "$baseUrl/bookings/sessions/get_session_by_shipment/$shipmentId/",
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      // =========================
      // STATUS HANDLING
      // =========================
      if (response.statusCode != 200) {
        throw Exception(
          "HTTP ${response.statusCode}: ${response.body}",
        );
      }

      // =========================
      // SAFE JSON PARSE
      // =========================
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid session response format');
      }

      return SessionModel.fromJson(decoded);
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ SessionApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }
      throw Exception("SessionApi.getSessionByShipment failed: $e");
    }
  }
}
