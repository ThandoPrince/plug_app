import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';



class AAddressCreationHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // ADD CLIENT ADDRESS
  // =========================
  static Future<http.Response> addClientAddress({
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse(
      "$baseUrl/clientsDB/client/a-add-residential-address/",
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

}