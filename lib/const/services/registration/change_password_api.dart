import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/const/services/registration/auth_login_api.dart'
    show ApiException;
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

/// Fresh token pair returned by the server after a successful password change.
/// The old tokens are already dead (session_version was bumped), so these
/// MUST be persisted immediately or the user gets logged out.
class ChangePasswordResult {
  final String accessToken;
  final String refreshToken;

  const ChangePasswordResult({
    required this.accessToken,
    required this.refreshToken,
  });
}

class ChangePasswordApi {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const Duration _timeout = Duration(seconds: 60);

  // Adjust to match ChangePasswordSerializer's field names if they differ.
  static Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/client/change-password/');
    final accessToken = AuthSessionController.instance.accessToken;

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
              'confirm_password': confirmPassword,
            }),
          )
          .timeout(_timeout);

      final data = _safeDecode(response.body);

      if (response.statusCode == 200 && data is Map) {
        final access = data['access']?.toString();
        final refresh = data['refresh']?.toString();

        if (access == null || refresh == null) {
          throw ApiException(
            statusCode: 500,
            data: {'error': 'Incomplete response from server'},
          );
        }

        return ChangePasswordResult(
          accessToken: access,
          refreshToken: refresh,
        );
      }

      if (response.statusCode == 429) {
        throw ApiException(
          statusCode: 429,
          data: {'error': 'Too many attempts. Please try again later.'},
        );
      }

      throw ApiException(statusCode: response.statusCode, data: data);
    } on TimeoutException {
      throw ApiException(statusCode: 408, data: {'error': 'Server timeout'});
    } on SocketException {
      throw ApiException(
        statusCode: 503,
        data: {'error': 'Server unreachable'},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        statusCode: 500,
        data: {'error': 'Unexpected error: $e'},
      );
    }
  }

  /// Gateways/proxies can return HTML on 502/504, so never trust jsonDecode.
  static dynamic _safeDecode(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'error': 'Unexpected server response'};
    }
  }
}