
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/retry_policy.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressCreationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // ADD CLIENT ADDRESS
  // =========================
  static Future<http.Response> addClientAddress({
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse(
      "$baseUrl/clientsDB/client/add-residential-address/",
    );

    final executor = RetryExecutor(
      policy: RetryPolicy.aggressive,
      onRetry: (attempt, error, delay) {
        if (kDebugMode) {
          print(
            'AddressCreationHelper.addClientAddress: '
            'retry attempt $attempt '
            'after ${delay.inMilliseconds}ms',
          );
        }
      },
    );

    final result = await executor.execute(() async {
      final response = await ApiClient.instance
          .request((token) {
            return http
                .post(
                  url,
                  headers: {
                    "Content-Type": "application/json",
                    if (token != null)
                      "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(data),
                )
                .timeout(_timeout);
          })
          .timeout(_timeout);

      // =========================
      // SUCCESS
      // =========================
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
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
      // OTHER HTTP ERRORS
      // =========================
      throw ApiException(
        statusCode: response.statusCode,
        body: response.body,
      );
    });

    // =========================
    // SUCCESS
    // =========================
    if (result.succeeded) {
      final response = result.value!;

      if (kDebugMode) {
        print(
          "Add Address Status: ${response.statusCode}",
        );
        print(
          "Add Address Body: ${response.body}",
        );
      }

      return response;
    }

    // =========================
    // ERROR HANDLING
    // =========================
    if (result.error is ApiException) {
      throw result.error!;
    }

    if (result.error is NetworkError) {
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

