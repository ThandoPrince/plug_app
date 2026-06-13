import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/client_auth.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<ClientAuthModel?> fetchClientAuth(String email) async {
    final url = Uri.parse('$baseUrl/client-auth/');

    try {
      final response = await http.get(
        url,
        headers: await ApiTokensHelper.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClientAuthModel.fromJson(data);
      } else {
        throw Exception("Error: ${response.statusCode} → ${response.body}");
      }
    } catch (e) {
      throw Exception("Exception fetching client auth: $e");
    }
  }
}
