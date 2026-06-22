import 'dart:convert';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_register_auth_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ClientAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Register Client Auth
  /// Register Client Auth
  static Future<ClientRegisterResponse> register({
    required String email,
    required String mobile,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/clientsDB/client/register/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
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

    // Pass the entire raw JSON map string inside the Exception 
    // so the controller's catch block can parse field errors dynamically
    throw Exception(response.body);
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
 Future<Map<String, dynamic>> updatePushToken({
    required String email,
    required String token,
    required String provider,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final authToken = AuthSessionController.instance.accessToken;
    final uri = Uri.parse(
      '$baseUrl/client_devices/register-device-token/',
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
        },
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
