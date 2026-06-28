

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';


class ApiHelper {
  ApiHelper._();
  static final ApiHelper instance = ApiHelper._();

  void Function()? onSessionExpired;

  static const Duration _timeout = Duration(seconds: 20);

  // =========================
  // Core Request Handler
  // =========================
  Future<http.Response> _send(
    Future<http.Response> Function(String? token) requestFn,
  ) async {
    String? token = AuthSessionController.instance.accessToken;

    try {
      http.Response response =
          await requestFn(token).timeout(_timeout);

      // 🔐 Handle expired access token
      if (response.statusCode == 401) {
        final newToken =
            await AuthSessionController.instance.refreshAccessToken();

        if (newToken == null) {
          await AuthSessionController.instance.clearSession();
          onSessionExpired?.call();
          throw AppException("Session expired");
        }

        response = await requestFn(newToken)
            .timeout(_timeout);
      }

      return response;
    } on TimeoutException {
      throw AppException("Request timed out. Try again.");
    } on http.ClientException {
      throw AppException("Network error. Check connection.");
    } catch (e) {
      throw AppException("Unexpected error occurred");
    }
  }

  // =========================
  // Public API methods
  // =========================

  Future<http.Response> get(Uri url) {
    return _send((token) {
      return http.get(
        url,
        headers: _headers(token),
      );
    });
  }

  Future<http.Response> post(Uri url, {Object? body}) {
    return _send((token) {
      return http.post(
        url,
        headers: _headers(token),
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> patch(Uri url, {Object? body}) {
    return _send((token) {
      return http.patch(
        url,
        headers: _headers(token),
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> delete(Uri url, {Object? body}) {
    return _send((token) {
      return http.delete(
        url,
        headers: _headers(token),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  // =========================
  // Headers
  // =========================
  Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  void setSessionExpiredHandler(void Function() handler) {
    onSessionExpired = handler;
  }
}

class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}