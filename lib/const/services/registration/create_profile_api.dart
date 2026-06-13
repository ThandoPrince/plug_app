import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class CreateProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? ''; 

  // PATCH request helper
  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    headers ??= {
      "Content-Type": "application/json",
    };

    // ✅ ADD AUTH HEADER
    final token = AuthSessionController.instance.accessToken;
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return await http.patch(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }
}