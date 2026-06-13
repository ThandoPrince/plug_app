import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/client_register_auth_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Register Client Auth
  static Future<ClientRegisterResponse> register({
  required String email,
  required String mobile,
  required String password,
}) async {

  final url = Uri.parse(
    "$baseUrl/clientsDB/client/register/",
  );

  final response = await http.post(
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

  final data = jsonDecode(response.body);

  if (response.statusCode == 201) {
    return ClientRegisterResponse.fromJson(data);
  }

  throw Exception(
    data["message"] ??
    data["error"] ??
    "Registration failed"
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
