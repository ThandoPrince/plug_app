import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/provider_qualification_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProviderQualificationsClientApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static const Duration _timeout = Duration(seconds: 60);

  static Future<List<ProviderQualificationModel>> fetchQualifications(
    int providerId,
    int serviceId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/client/provider-qualifications/$providerId/$serviceId',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              uri,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("=== PROVIDER QUALIFICATIONS ===");
        print("URL: $uri");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
      }

      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final List data = decoded["data"] ?? [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(ProviderQualificationModel.fromJson)
          .toList();
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } on SocketException {
      throw Exception("Server unreachable. Check your internet connection.");
    }
  }

  static String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded["message"] ??
            decoded["error"] ??
            decoded["detail"] ??
            "Request failed.";
      }
    } catch (_) {}

    return "Request failed (${response.statusCode}).";
  }
}