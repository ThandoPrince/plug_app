import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DefaultAddressApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  /// Set default address for a client
  static Future<void> setDefaultAddress({
    required int addressId,
  }) async {
    final clientId = AuthSessionController.instance.clientId;

    final url = Uri.parse(
      '$baseUrl/clientsDB/set-default-address/$clientId/',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .post(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
              body: jsonEncode({
                "address_id": addressId,
              }),
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== DEFAULT ADDRESS ==========");
        print("URL: $url");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("====================================");
      }

      if (response.statusCode == 200) {
        return;
      }

      String message = "Failed to set default address.";

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          message = decoded["message"] ??
              decoded["error"] ??
              decoded["detail"] ??
              message;
        }
      } catch (_) {
        // Ignore invalid JSON and use the default message.
      }

      throw Exception(message);
    } on TimeoutException {
      throw Exception(
        "Server timeout. Please try again.",
      );
    } on SocketException {
      throw Exception(
        "Server unreachable. Check your internet connection.",
      );
    } catch (e) {
      rethrow;
    }
  }
}