import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class DefaultAddressPatchApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 10);

  // =========================
  // SET DEFAULT ADDRESS
  // =========================
  Future<bool> setDefaultAddress({
    required int addressId,
  }) async {
    final clientId = AuthSessionController.instance.clientId;

    final url = Uri.parse(
      '$baseUrl/address-client/set-default/$addressId/?id=$clientId',
    );

    try {
      final response = await ApiClient.instance.request((token) async {
        return await http
            .patch(
              url,
              headers: {
                "Content-Type": "application/json",
                if (token != null) "Authorization": "Bearer $token",
              },
            )
            .timeout(_timeout);
      }).timeout(_timeout);

      if (kDebugMode) {
        print("========== DEFAULT ADDRESS ==========");
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        print("=====================================");
      }

      return response.statusCode == 200;

    } on TimeoutException {
      if (kDebugMode) {
        print("DefaultAddress timeout");
      }
      return false;

    } on SocketException {
      if (kDebugMode) {
        print("DefaultAddress server unreachable");
      }
      return false;

    } catch (e) {
      if (kDebugMode) {
        print("DefaultAddress unexpected error: $e");
      }
      return false;
    }
  }
}