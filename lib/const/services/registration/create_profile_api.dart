import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CreateProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? ''; 

  // PATCH request helper
  static Future<http.Response> patch(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    headers ??= {"Content-Type": "application/json"};

    return await http.patch(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Optional: GET, POST, DELETE helpers can go here
}
