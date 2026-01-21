import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DefaultAddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Call the backend API to set the default address for a client email
  static Future<void> getDefaultAddress(String email, int addressId) async {
    final url = Uri.parse('$baseUrl/clientsDB/set-default-address/$email/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'address_id': addressId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set default address');
    }
  }
}
