import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/order_service_models/sp_rating_model.dart';

class SPRatingApi {
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
  // RETRY WRAPPER (SAFE FOR GET)
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
  // FETCH RATINGS
  // =========================
  static Future<List<SPRatingModel>> fetchRatings(
    int providerId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/client/get-sp-ratings/$providerId/',
    );

    try {
      final response = await _withRetry(() async {
        return await ApiClient.instance.request((token) async {
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
      });

      // Optional structured debug
      if (true) {
        // you can replace with kDebugMode if preferred
        // kept simple for consistency
        // ignore: avoid_print
        print("========== SP RATINGS ==========");
        // ignore: avoid_print
        print("URL: $url");
        // ignore: avoid_print
        print("STATUS: ${response.statusCode}");
        // ignore: avoid_print
        print("BODY: ${response.body}");
        // ignore: avoid_print
        print("================================");
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid rating response format.");
      }

      final rawData = decoded['data'];

      if (rawData == null) {
        return [];
      }

      if (rawData is! List) {
        throw Exception("Invalid 'data' format in rating response.");
      }

      return rawData
          .whereType<Map<String, dynamic>>()
          .map(SPRatingModel.fromJson)
          .toList();

    } catch (e) {
      throw _handleError(e);
    }
  }
}