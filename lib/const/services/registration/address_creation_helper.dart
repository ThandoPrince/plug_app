import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressCreationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<http.Response> addClientAddress({
    required Map<String, dynamic> data,
    required String email,
  }) async {
    final url = Uri.parse(
      "$baseUrl/clientsDB/client/$email/add-residential-address/",
    );

    const headers = {"Content-Type": "application/json"};

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> updatePushToken({
    required String email,
    required String token,
    required String provider,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final url = Uri.parse(
      "$baseUrl/client_devices/register-device-token/",
    );

    const headers = {"Content-Type": "application/json"};

    return await http.post(
      url,
      headers: headers,
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
  }
}