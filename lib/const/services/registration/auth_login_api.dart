import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/client_models/client_login_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthLoginApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// ---------------- LOGIN ----------------
    Future<ClientLoginResponse> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/clientsDB/login/');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "identifier": identifier.toLowerCase().trim(),
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ClientLoginResponse.fromJson(decoded['data']);
    }

    throw Exception(data['error'] ?? data['message'] ?? "Login failed");
  }

  /// ---------------- PUSH TOKEN REGISTER ----------------
  Future<Map<String, dynamic>> updatePushToken({
    required String email,
    required String token,
    required String provider,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/client_devices/register-device-token/',
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email.toLowerCase(),
          "push_token": token,
          "device_type": deviceType,
          "device_name": deviceName,
          "os_version": osVersion,
          "app_version": appVersion,
          "provider": provider,
        }),
      );

      final data = jsonDecode(response.body);

      // Accept both:
      // 200 = updated existing token
      // 201 = created new token
      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "statusCode": response.statusCode,
          "data": data,
        };
      }

      return {
        "statusCode": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "error": "Failed to update push token: $e",
        },
      };
    }
  }
}