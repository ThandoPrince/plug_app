import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/client_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ClientAuthApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static Future<ClientAuthModel?> fetchClientAuth(String email) async {
    final url = Uri.parse('$baseUrl/client-auth/$email/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClientAuthModel.fromJson(data);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception fetching client auth: $e");
      return null;
    }
  }
}