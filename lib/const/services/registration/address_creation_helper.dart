import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';



class AddressCreationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // ADD CLIENT ADDRESS
  // =========================
  static Future<http.Response> addClientAddress({
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse(
      "$baseUrl/clientsDB/client/add-residential-address/",
    );

    final response = await ApiClient.instance.request((token) {
      return http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
    });

    if (kDebugMode) {
      print("Add Address Status: ${response.statusCode}");
      print("Add Address Body: ${response.body}");
    }

    return response;
  }

  // =========================
  // UPDATE PUSH TOKEN
  // =========================
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

    final response = await ApiClient.instance.request((authToken) {
      return http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (authToken != null)
            "Authorization": "Bearer $authToken",
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
    });

    if (kDebugMode) {
      print("Push Token Status: ${response.statusCode}");
      print("Push Token Body: ${response.body}");
    }

    return response;
  }
}