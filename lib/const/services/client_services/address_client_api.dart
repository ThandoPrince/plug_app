import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddressClientsApi {
static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch all addresses associated with a client by email
static Future<List<AddressClientModel>> getAddressClients(String email) async {
  final response = await http.get(Uri.parse('$baseUrl/clientsDB/client-addresses/$email/'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>; // ✅ top-level is a list

    return data
        .map<AddressClientModel>((json) => AddressClientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else if (response.statusCode == 404) {
    return []; // No addresses for this client
  } else {
    throw Exception('Failed to load addresses: ${response.statusCode}');
  }
}

  /// Set the default address for a client
  static Future<void> setDefaultAddress(String email, int clientAddressId) async {
    final url = Uri.parse('$baseUrl/set-default-address/$email/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'client_address_id': clientAddressId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set default address: ${response.body}');
    }
  }
}
