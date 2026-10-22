import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/cost_of_service_image.dart';

class CostOfServiceImageApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // ERROR HANDLER
  // =========================
  static Exception _handleError(Object e) {
    if (e is TimeoutException) {
      return Exception("Server timeout. Please try again.");
    }

    if (e is SocketException) {
      return Exception("Server unreachable. Check your internet connection.");
    }

    return Exception("Unexpected error occurred.");
  }

  // =========================
  // FETCH IMAGES BY COST ID
  // =========================
  static Future<List<CostOfServiceImageModel>> fetchImagesByCostId(
    int costId,
  ) async {
    final url = Uri.parse('$baseUrl/cost_of_service/$costId/images/');

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

      // =========================
      // DEBUG LOGGING
      // =========================
      if (kDebugMode) {
        print("========== COST IMAGES ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=================================");
      }

      // =========================
      // BUSINESS CASE: NO IMAGES
      // =========================
      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception("Invalid image response format.");
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CostOfServiceImageModel.fromJson)
          .toList();

    } catch (e) {
      throw _handleError(e);
    }
  }
}