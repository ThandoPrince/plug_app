import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';

class CostOfServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

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
  // SINGLE PROVIDER + SERVICE
  // =========================
  static Future<CostOfServiceModel?> fetchCostByEmailAndService(
    int providerId,
    int serviceId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/cost_of_service/$providerId/$serviceId/',
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
        print("========== COST OF SERVICE ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=====================================");
      }

      // 404 is valid business case → no cost exists
      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid cost response format.");
      }

      return CostOfServiceModel.fromJson(decoded);

    } catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // MULTIPLE PROVIDERS (PARALLEL SAFE)
  // =========================
  static Future<List<CostOfServiceModel>> fetchCostsByEmailsAndService(
    List<int> providerIds,
    int serviceId,
  ) async {
    if (providerIds.isEmpty) return [];

    try {
      final futures = providerIds.map(
        (providerId) => fetchCostByEmailAndService(providerId, serviceId),
      );

      final results = await Future.wait(futures);

      return results.whereType<CostOfServiceModel>().toList();

    } catch (e) {
      if (kDebugMode) {
        print("========== COST BATCH ERROR ==========");
        print(e);
        print("======================================");
      }

      return [];
    }
  }
}