
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/retry_policy.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ServiceProvidersByAddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // RETRY EXECUTOR
  // =========================
  static RetryExecutor _createRetryExecutor(String operation) {
    return RetryExecutor(
      policy: RetryPolicy.aggressive,
      onRetry: (attempt, error, delay) {
        if (kDebugMode) {
          print(
            'ServiceProvidersByAddressApi.$operation: '
            'retry attempt $attempt '
            'after ${delay.inMilliseconds}ms',
          );
        }
      },
    );
  }

  // =========================
  // SINGLE ADDRESS
  // =========================
  static Future<List<ServiceProviderModel>> fetchProvidersByAddress(
    int addressId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/service_providerDB/sps_by_live_location/$addressId/',
    );

    return _fetchProviders(url, 'fetchProvidersByAddress');
  }

  // =========================
  // MULTIPLE ADDRESSES
  // =========================
  static Future<List<ServiceProviderModel>> fetchProvidersByAddresses(
    List<int> addressIds,
  ) async {
    if (addressIds.isEmpty) return [];

    final idsQuery = addressIds.join(',');

    final url = Uri.parse(
      '$baseUrl/service_providerDB/sps_by_live_location/?ids=$idsQuery',
    );

    return _fetchProviders(url, 'fetchProvidersByAddresses');
  }

  // =========================
  // CORE FETCH
  // =========================
  static Future<List<ServiceProviderModel>> _fetchProviders(
    Uri url,
    String operation,
  ) async {
    final executor = _createRetryExecutor(operation);

    final result = await executor.execute(() async {
      final response = await ApiClient.instance
          .request((token) {
            return http
                .get(
                  url,
                  headers: {
                    "Content-Type": "application/json",
                    if (token != null)
                      "Authorization": "Bearer $token",
                  },
                )
                .timeout(_timeout);
          })
          .timeout(_timeout);

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode == 200) {
        return response;
      }

      // =========================
      // DON'T RETRY CLIENT ERRORS
      // =========================
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        throw ApiException(
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      // =========================
      // RETRY TRANSIENT HTTP ERRORS
      // =========================
      if (RetryPolicy.aggressive
          .isRetriableStatusCode(response.statusCode)) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: url,
        );
      }

      // =========================
      // OTHER HTTP ERROR
      // =========================
      throw ApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    });

    if (result.succeeded) {
      final response = result.value!;

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final List providersJson = decoded['service_providers'] ?? [];

      return providersJson
          .map((e) => ServiceProviderModel.fromJson(e))
          .toList();
    }

    // =========================
    // ERROR CONVERSION
    // =========================
    if (result.error is ApiException) {
      throw result.error!;
    }

    if (result.error is TimeoutException) {
      throw NetworkError.fromException(
        result.error!,
        statusCode: 408,
      );
    }

    if (result.error is SocketException) {
      throw NetworkError.fromException(
        result.error!,
        statusCode: 503,
      );
    }

    if (result.error is NetworkError) {
      throw result.error!;
    }

    throw result.error!;
  }
}

// =========================
// API EXCEPTION
// =========================
class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException({
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() {
    return 'HTTP $statusCode: $body';
  }
}

