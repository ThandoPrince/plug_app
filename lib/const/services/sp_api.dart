import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

class ServiceProviderApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // ERROR MAPPER
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
  // RETRY WRAPPER
  // =========================
  static Future<T> _withRetry<T>(
    Future<T> Function() request, {
    int retries = 2,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    try {
      return await request();
    } catch (e) {
      if (retries <= 0) rethrow;

      await Future.delayed(delay);
      return _withRetry(
        request,
        retries: retries - 1,
        delay: delay * 2,
      );
    }
  }

  // =========================
  // FETCH ALL SERVICE PROVIDERS BY SERVICE ID
  // =========================
  static Future<List<ServiceProviderModel>> fetchAllServiceProviders(
    int serviceId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/service_providers/?service_id=$serviceId',
    );

    try {
      final response = await _withRetry(() async {
        return await ApiClient.instance.request((token) {
          return http
              .get(
                url,
                headers: {
                  "Content-Type": "application/json",
                  if (token != null) "Authorization": "Bearer $token",
                },
              )
              .timeout(_timeout);
        }).timeout(_timeout);
      });

      if (kDebugMode) {
        print("========== SERVICE PROVIDERS ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=======================================");
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception("Invalid response format (expected List).");
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ServiceProviderModel.fromJson)
          .toList();

    } catch (e) {
      throw _handleError(e);
    }
  }
}