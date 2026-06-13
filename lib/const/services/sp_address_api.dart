import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/models/sp_address_model.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';

class AddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // FETCH BY ID
  // =========================
  static Future<SpAddressModel> fetchAddressById(int id) async {
    final url = Uri.parse('$baseUrl/serviceProvidersDB/address/$id/');

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid address response format');
      }

      return SpAddressModel.fromJson(decoded);
    } catch (e) {
      throw Exception('AddressApi.fetchAddressById error: $e');
    }
  }

  // =========================
  // FETCH ALL
  // =========================
  static Future<List<SpAddressModel>> fetchAllAddresses() async {
    final url = Uri.parse('$baseUrl/address/');

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid address list format');
      }

      return decoded.map((item) => SpAddressModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('AddressApi.fetchAllAddresses error: $e');
    }
  }
}
