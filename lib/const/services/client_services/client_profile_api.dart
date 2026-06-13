import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class ClientProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH CLIENT BY EMAIL
  // =========================
  static Future<ClientDetailModel> fetchClientProfileByEmail(
    int clientid,
  ) async {
    final url = Uri.parse(
      '$baseUrl/clientsDB/clients/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Client Profile HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load profile: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid client profile format');
      }

      return ClientDetailModel.fromJson(decoded);
    } catch (e) {
      if (kDebugMode) {
        print('ClientProfileApi error: $e');
      }
      throw Exception('Error fetching profile: $e');
    }
  }

  // =========================
  // FETCH ALL CLIENTS
  // =========================
  static Future<List<ClientDetailModel>> fetchClientProfile() async {
    final url = Uri.parse(
      '$baseUrl/clientsDB/clients/',
    );

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (kDebugMode) {
        print("Client List HTTP: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load profiles: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid client list format');
      }

      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid client item format');
        }
        return ClientDetailModel.fromJson(item);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('ClientProfileApi error: $e');
      }
      throw Exception('Error fetching profiles: $e');
    }
  }
}
