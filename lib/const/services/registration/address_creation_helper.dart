import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressCreationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // POST request for adding a new client address
  static Future<http.Response> addClientAddress({
    required Map<String, dynamic> data,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/clientsDB/client/$email/add-residential-address/");

    final headers = {"Content-Type": "application/json"};

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }
}
