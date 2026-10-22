import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/sp_address_model.dart';

class AddressApi {
  AddressApi._();

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
  // FETCH BY ID
  // =========================
  static Future<SpAddressModel> fetchAddressById(int id) async {
    final url = Uri.parse('$baseUrl/serviceProvidersDB/address/$id/');

    try {
      final response = await _withRetry(() async {
        return await ApiClient.instance.request((token) async {
          return await http
              .get(
                url,
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token",
                },
              )
              .timeout(_timeout);
        }).timeout(_timeout);
      });

      if (kDebugMode) {
        print("========== ADDRESS BY ID ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("===================================");
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid address response format.");
      }

      return SpAddressModel.fromJson(decoded);

    } catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // FETCH ALL
  // =========================
  static Future<List<SpAddressModel>> fetchAllAddresses() async {
    final url = Uri.parse('$baseUrl/address/');

    try {
      final response = await _withRetry(() async {
        return await ApiClient.instance.request((token) async {
          return await http
              .get(
                url,
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token",
                },
              )
              .timeout(_timeout);
        }).timeout(_timeout);
      });

      if (kDebugMode) {
        print("========== ADDRESS LIST ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("==================================");
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception("Invalid address list format.");
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SpAddressModel.fromJson)
          .toList();

    } catch (e) {
      throw _handleError(e);
    }
  }
}