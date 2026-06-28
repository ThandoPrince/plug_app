import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/sp_profile_model.dart';

class SpProfileApi {
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
  // FETCH PROFILE BY EMAIL
  // =========================
  static Future<SPProfileModel> fetchProfileByEmail(String email) async {
    final url = Uri.parse('$baseUrl/sp_profiles/$email/');

    try {
      final response = await ApiClient.instance
          .request(
            (token) async {
              return await http
                  .get(
                    url,
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                  )
                  .timeout(_timeout);
            },
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print("========== SP PROFILE API ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("====================================");
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid profile response format.");
      }

      return SPProfileModel.fromJson(decoded);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =========================
  // FETCH ALL PROFILES
  // =========================
  static Future<List<SPProfileModel>> fetchAllProfiles() async {
    final url = Uri.parse('$baseUrl/sp_profiles/');

    try {
      final response = await ApiClient.instance
          .request(
            (token) async {
              return await http
                  .get(
                    url,
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                  )
                  .timeout(_timeout);
            },
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print("========== SP PROFILE LIST ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("====================================");
      }

      if (response.statusCode != 200) {
        throw Exception("Server error (${response.statusCode}).");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception("Invalid list response format.");
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => SPProfileModel.fromJson(e))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
}