import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 15);

  // =========================
  // FETCH SINGLE CLIENT PROFILE
  // =========================
  static Future<ClientDetailModel> fetchClientProfile() async {
    final decoded = await _getJson(
      Uri.parse('$baseUrl/clientsDB/clients/'),
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid client profile format.');
    }

    return ClientDetailModel.fromJson(decoded);
  }

  // =========================
  // FETCH ALL CLIENTS
  // =========================
  static Future<List<ClientDetailModel>> fetchAllClients() async {
    final decoded = await _getJson(
      Uri.parse('$baseUrl/clientsDB/clients/'),
    );

    if (decoded is! List) {
      throw Exception('Invalid client list format.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ClientDetailModel.fromJson)
        .toList();
  }

  // =========================
  // COMMON GET REQUEST
  // =========================
  static Future<dynamic> _getJson(Uri url) async {
    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .get(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null)
                  "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== CLIENT PROFILE API ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("========================================");
      }

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception(
        "Server timeout. Please try again.",
      );
    } on SocketException {
      throw Exception(
        "Server unreachable. Check your internet connection.",
      );
    }
  }

  // =========================
  // ERROR PARSER
  // =========================
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