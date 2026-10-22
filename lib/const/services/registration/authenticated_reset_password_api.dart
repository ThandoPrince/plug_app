import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/registration/auth_login_api.dart'
    show ApiException;
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class PasswordResetChallenge {
  final String otpRequestId;
  final String maskedEmail;
  const PasswordResetChallenge({
    required this.otpRequestId,
    required this.maskedEmail,
  });
}

class PasswordResetResult {
  final String accessToken;
  final String refreshToken;
  const PasswordResetResult({
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthenticatedResetPasswordApi {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const Duration _timeout = Duration(seconds: 60);

  // Step 1: server emails a code to the logged-in client's address.
  static Future<PasswordResetChallenge> requestOtp() async {
    final data = await _post('/client/request-password-reset-otp/', const {});

    final inner = data is Map ? data['data'] : null;
    final id = inner is Map ? inner['otp_request_id']?.toString() : null;
    if (id == null || id.isEmpty) {
      throw ApiException(
        statusCode: 500,
        data: {'error': 'Incomplete response from server'},
      );
    }
    return PasswordResetChallenge(
      otpRequestId: id,
      maskedEmail: (inner['masked_email'] ?? '').toString(),
    );
  }

  // Step 2: verify code + set new password. Returns a fresh token pair.
  static Future<PasswordResetResult> confirmReset({
    required String otp,
    required String otpRequestId,
    required String newPassword,
  }) async {
    final data = await _post('/client/reset-password-with-otp/', {
      'otp': otp,
      'otp_request_id': otpRequestId,
      'new_password': newPassword,
    });

    final access = data is Map ? data['access']?.toString() : null;
    final refresh = data is Map ? data['refresh']?.toString() : null;
    if (access == null || refresh == null) {
      throw ApiException(
        statusCode: 500,
        data: {'error': 'Incomplete response from server'},
      );
    }
    return PasswordResetResult(accessToken: access, refreshToken: refresh);
  }

  /// Returns decoded body on 200, throws ApiException otherwise.
  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final accessToken = AuthSessionController.instance.accessToken;

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = _safeDecode(response.body);
      if (response.statusCode == 200) return data;

      throw ApiException(statusCode: response.statusCode, data: data);
    } on TimeoutException {
      throw ApiException(statusCode: 408, data: {'error': 'Server timeout'});
    } on SocketException {
      throw ApiException(statusCode: 503, data: {'error': 'Server unreachable'});
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 500, data: {'error': 'Unexpected error: $e'});
    }
  }

  static dynamic _safeDecode(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'error': 'Unexpected server response'};
    }
  }
}