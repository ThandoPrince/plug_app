import 'dart:convert';
import 'package:flutter_application_1/global_util/services/api_client.dart';
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
      '$baseUrl/service_providerDB/sps_by_live_location/$addressId/',
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
      '$baseUrl/service_providerDB/sps_by_live_location/?ids=$idsQuery',
    );

    return _fetchProviders(url);
  }

  // =========================
  // CORE FETCH (CLEAN)
  // =========================
  static Future<List<ServiceProviderModel>> _fetchProviders(Uri url) async {
    final response = await ApiClient.instance.request((token) {
      return http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final List providersJson = decoded['service_providers'] ?? [];

    return providersJson
        .map((e) => ServiceProviderModel.fromJson(e))
        .toList();
  }
}