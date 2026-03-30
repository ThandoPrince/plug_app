import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Register Client Auth
  static Future<http.Response> register({
    required String email,
    required String mobile,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/clientsDB/client/register/");

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email_address": email.toLowerCase(),
        "mobile_number": mobile,
        "password": password,
      }),
    );
  }

  /// Patch Client Details (email-based lookup)
  static Future<http.Response> patchDetails({
    required String email,
    required Map<String, dynamic> data,
  }) async {
    final url =
        Uri.parse("$baseUrl/client/details/update/?email=$email");

    return await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
  }
}
