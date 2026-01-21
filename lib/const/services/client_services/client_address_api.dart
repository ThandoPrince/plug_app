import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart' show ClientAddressModel;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<ClientAddressModel>> getClientAddresses(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/clientsDB/address-only/$email'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> addresses = data['addresses'];

      return addresses
          .map<ClientAddressModel>((json) => ClientAddressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  /// Set the default address for a client by sending the client_address_id
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
