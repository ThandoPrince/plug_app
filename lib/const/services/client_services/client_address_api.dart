import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class AddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // GET CLIENT ADDRESSES
  // =========================
  static Future<List<ClientAddressModel>> getClientAddresses() async {
    final id =  AuthSessionController.instance.clientId;
    final url = Uri.parse(
      '$baseUrl/clientsDB/address-only/$id',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Client Addresses HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load addresses: ${response.body}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid address response format');
      }

      final addresses = decoded['addresses'];

      if (addresses is! List) {
        throw Exception('Invalid addresses list format');
      }

      return addresses.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid address item format');
        }
        return ClientAddressModel.fromJson(item);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('AddressApi error: $e');
      }
      throw Exception('Error fetching addresses: $e');
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
      final response = await http.post(
        url,
        headers: await ApiTokensHelper.authHeaders(),
        body: jsonEncode({
          'client_address_id': clientAddressId,
        }),
      );

      if (kDebugMode) {
        print("Set Default Address HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set default address: ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('AddressApi error: $e');
      }
      rethrow;
    }
  }
}
