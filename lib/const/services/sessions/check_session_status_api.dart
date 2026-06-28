import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CheckSessionStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 10);

  // =========================
  // FETCH SESSION STATUS (BOOLEAN SAFE)
  // =========================
  static Future<bool> isSessionCompleted(int sessionId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/sessions/$sessionId/check_status/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== SESSION STATUS ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("====================================");
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
        print("CheckSessionStatusApi error: $e");
      }
      return false;
    }
  }
}