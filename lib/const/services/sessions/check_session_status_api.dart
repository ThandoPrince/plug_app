import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class CheckSessionStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> isSessionCompleted(int sessionId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/sessions/$sessionId/check_status/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print('🔥 HTTP ${response.statusCode}: ${response.body}');
      }

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final status = decoded['status'];

      if (status is! String) {
        return false;
      }

      return status.toLowerCase() == 'completed';
    } catch (e) {
      if (kDebugMode) {
        print('CheckSessionStatusApi error: $e');
      }
      return false;
    }
  }
}
