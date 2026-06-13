import 'dart:convert';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';


class ServiceProvidersByAddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // SINGLE ADDRESS
  // =========================
  static Future<List<ServiceProviderModel>> fetchProvidersByAddress(
    int addressId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/service_providersDB/sps_by_live_location/$addressId/',
    );

    return _fetchProviders(url);
  }

  // =========================
  // MULTIPLE ADDRESSES
  // =========================
  static Future<List<ServiceProviderModel>> fetchProvidersByAddresses(
    List<int> addressIds,
  ) async {
    if (addressIds.isEmpty) return [];

    final idsQuery = addressIds.join(',');

    final url = Uri.parse(
      '$baseUrl/service_providersDB/sps_by_live_location/?ids=$idsQuery',
    );

    return _fetchProviders(url);
  }

  // =========================
  // SHARED FETCH LOGIC
  // =========================
  static Future<List<ServiceProviderModel>> _fetchProviders(
  Uri url,
) async {
  try {
    final response = await http.get(
      url,
      headers: await ApiTokensHelper.authHeaders(),
    );

    // =========================
    // CHECK STATUS FIRST
    // =========================
    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    // =========================
    // SAFE JSON PARSE
    // =========================
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final List<dynamic> providersJson =
        decoded['service_providers'] ?? [];

    return providersJson
        .map((e) => ServiceProviderModel.fromJson(e))
        .toList();
  } catch (e) {
    throw Exception('Service provider fetch error: $e');
  }
}
}