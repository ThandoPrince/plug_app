import 'dart:io';

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:http/http.dart' as http;

import '../../const/services/retry_policy.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  void Function()? onSessionExpired;
  String? getAccessToken() {
  return AuthSessionController.instance.accessToken;
}

  Future<http.Response> multipartRequest(
  Future<http.MultipartRequest> Function(String? token) builder,
) async {
  String? token = AuthSessionController.instance.accessToken;

  http.MultipartRequest request = await builder(token);

  http.StreamedResponse streamed = await request.send();
  http.Response response = await http.Response.fromStream(streamed);

  if (response.statusCode == 401) {
    final newToken =
        await AuthSessionController.instance.refreshAccessToken();

    if (newToken == null) {
      await AuthSessionController.instance.clearSession();
      throw Exception("Session expired");
    }

    request = await builder(newToken);
    streamed = await request.send();
    response = await http.Response.fromStream(streamed);
  }

  return response;
}

  void setSessionExpiredHandler(void Function() handler) {
    onSessionExpired = handler;
  }

  Future<http.Response> request(
    Future<http.Response> Function(String? token) action,
  ) async {
    String? token = AuthSessionController.instance.accessToken;

    http.Response response = await action(token);

    if (response.statusCode == 401) {
      final newToken =
          await AuthSessionController.instance.refreshAccessToken();

      if (newToken == null) {
        await AuthSessionController.instance.clearSession();

        onSessionExpired?.call();

        throw Exception("Session expired");
      }

      response = await action(newToken);
    }

    return response;
  }

  /// Execute a request with retry policy and proper error classification.
  Future<RetryResult<http.Response>> requestWithRetry(
    Future<http.Response> Function(String? token) action, {
    RetryPolicy policy = RetryPolicy.aggressive,
  }) async {
    return RetryExecutor(policy: policy).execute(() async {
      String? token = AuthSessionController.instance.accessToken;
      http.Response response = await action(token);

      // Handle 401 with token refresh (not retriable - let refresh happen once)
      if (response.statusCode == 401) {
        final newToken =
            await AuthSessionController.instance.refreshAccessToken();

        if (newToken == null) {
          await AuthSessionController.instance.clearSession();
          onSessionExpired?.call();
          throw NetworkError.fromException(
            Exception("Session expired"),
            statusCode: 401,
          );
        }

        response = await action(newToken);
      }

      // Check for retriable status codes
      if (policy.isRetriableStatusCode(response.statusCode)) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: Uri.parse(''),
        );
      }

      return response;
    });
  }

  /// Execute multipart request with retry policy.
  Future<RetryResult<http.Response>> multipartRequestWithRetry(
    Future<http.MultipartRequest> Function(String? token) builder, {
    RetryPolicy policy = RetryPolicy.aggressive,
  }) async {
    return RetryExecutor(policy: policy).execute(() async {
      String? token = AuthSessionController.instance.accessToken;
      http.MultipartRequest request = await builder(token);
      http.StreamedResponse streamed = await request.send();
      http.Response response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401) {
        final newToken =
            await AuthSessionController.instance.refreshAccessToken();

        if (newToken == null) {
          await AuthSessionController.instance.clearSession();
          throw NetworkError.fromException(
            Exception("Session expired"),
            statusCode: 401,
          );
        }

        request = await builder(newToken);
        streamed = await request.send();
        response = await http.Response.fromStream(streamed);
      }

      if (policy.isRetriableStatusCode(response.statusCode)) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: Uri.parse(''),
        );
      }

      return response;
    });
  }
}
