import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/household_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HouseholdPage {
  final List<HouseHoldModel> items;
  final bool hasNext;
  const HouseholdPage(this.items, this.hasNext);
}

class HouseholdApiHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // GET HOUSEHOLD MEMBERS (paginated)
  // =========================
  static Future<HouseholdPage> getHouseholdMembersPage(
    int clientAddressId, {
    int page = 1,
    int pageSize = 15,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/client-address/$clientAddressId/household-members/',
    ).replace(queryParameters: {'page': '$page', 'page_size': '$pageSize'});

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
        print("HOUSEHOLD MEMBERS ${response.statusCode} $uri");
      }

      if (response.statusCode == 404) return const HouseholdPage([], false);

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final List data = decoded["data"] ?? [];
      final items = data
          .whereType<Map<String, dynamic>>()
          .map(HouseHoldModel.fromJson)
          .toList();

      // An old backend sends no has_next, which safely means "no more".
      return HouseholdPage(items, decoded["has_next"] == true);
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } on SocketException {
      throw Exception("Server unreachable. Check your internet connection.");
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