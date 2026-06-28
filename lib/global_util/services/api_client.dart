import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:http/http.dart' as http;

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
}