import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddressesPage {
  final List<AddressClientModel> items;
  final bool hasNext;
  const AddressesPage(this.items, this.hasNext);
}

class AddressClientsApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // GET CLIENT ADDRESSES (paginated)
  // =========================
  static Future<AddressesPage> getAddressesPage({
    int page = 1,
    int pageSize = 15,
  }) async {
    final clientId = AuthSessionController.instance.clientId;

    final url = Uri.parse('$baseUrl/clientsDB/client-addresses/$clientId/')
        .replace(queryParameters: {'page': '$page', 'page_size': '$pageSize'});

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

      if (kDebugMode) print("CLIENT ADDRESSES ${response.statusCode} $url");

      // Past page 1, a 404 means "no more". On page 1 it means no addresses.
      if (response.statusCode == 404) return const AddressesPage([], false);

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['results'] is! List) {
        throw Exception("Invalid response format.");
      }

      final items = (decoded['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AddressClientModel.fromJson)
          .toList();

      return AddressesPage(items, decoded['next'] != null);
    } on TimeoutException {
      throw Exception("Server timeout. Please try again.");
    } on SocketException {
      throw Exception("Server unreachable. Check your internet connection.");
    }
  }

  // =========================
  // SET DEFAULT ADDRESS
  // =========================
  static Future<void> setDefaultAddress({
    required String email,
    required int clientAddressId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/set-default-address/$email/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
                "client_address_id": clientAddressId,
              }),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("SET DEFAULT ADDRESS ${response.statusCode} $url");
      }

      if (response.statusCode != 200) {
        throw Exception(_extractError(response));
      }
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