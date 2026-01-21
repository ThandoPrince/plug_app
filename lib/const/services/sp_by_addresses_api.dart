import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ServiceProvidersByAddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch all SPs linked to a single address (old style)
  static Future<List<ServiceProviderModel>> fetchProvidersByAddress(int addressId) async {
    final url = Uri.parse('$baseUrl/service_providersDB/sps_by_live_location/$addressId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> providersJson = data['service_providers'] ?? [];
      return providersJson
          .map((json) => ServiceProviderModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load service providers');
    }
  }

  /// ✅ New: Fetch SPs for multiple addresses with ?ids=2,1
  static Future<List<ServiceProviderModel>> fetchProvidersByAddresses(List<int> addressIds) async {
    if (addressIds.isEmpty) return [];

    final idsQuery = addressIds.join(',');
    final url = Uri.parse('$baseUrl/service_providersDB/sps_by_live_location/?ids=$idsQuery');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> providersJson = data['service_providers'] ?? [];
      return providersJson
          .map((json) => ServiceProviderModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load service providers for multiple addresses');
    }
  }
}
