import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_application_1/global_util/services/api_exeption.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

// NOTE: assumes ApiHelper is your authenticated request wrapper


class LogoutApi {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static const Duration _timeout = Duration(seconds: 60);

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    final url = Uri.parse("$_baseUrl/clientsDB/client-logout/");

    final payload = {
      "refresh": AuthSessionController.instance.refreshToken,
    };

    debugPrint("========== LOGOUT REQUEST ==========");
    debugPrint("URL: $url");
    debugPrint("PAYLOAD: ${jsonEncode(payload)}");
    debugPrint("REFRESH TOKEN: ${AuthSessionController.instance.refreshToken}");
    debugPrint("===================================");

    try {
      final response = await ApiHelper.instance
          .post(
            url,
            body: payload,
          )
          .timeout(_timeout);

      debugPrint("========== LOGOUT RESPONSE ==========");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("====================================");

      // =========================
      // CRITICAL: ALWAYS CLEAR LOCAL SESSION
      // =========================
      await AuthSessionController.instance.clearSession();

      if (response.statusCode != 200) {
        throw AppException("Logout failed on server");
      }

    } on TimeoutException {
      await AuthSessionController.instance.clearSession();
      throw AppException("Server timeout. Please try again.");

    } on SocketException {
      await AuthSessionController.instance.clearSession();
      throw AppException("Server unreachable. Check your internet connection.");

    } on AppException {
      await AuthSessionController.instance.clearSession();
      rethrow;

    } catch (_) {
      await AuthSessionController.instance.clearSession();
      throw AppException("Something went wrong during logout");
    }
  }
}