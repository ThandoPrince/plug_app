import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:http/http.dart' as http;

class ApiTokensHelper {
  static Future<Map<String, String>> authHeaders() async {
    final auth = AuthSessionController.instance;

    if (auth.accessToken == null) {
      await auth.loadSession();
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${auth.accessToken}",
    };
  }
}

class AuthHttpClient {
  static Future<http.Response> post(
    Uri url, {
    required Map<String, String> headers,
    Object? body,
  }) async {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 401) {
      final newToken =
          await AuthSessionController.instance.refreshAccessToken();

      if (newToken != null) {
        final retry = await http.post(
          url,
          headers: {
            ...headers,
            "Authorization": "Bearer $newToken",
          },
          body: body,
        );

        return retry;
      }
    }

    return response;
  }
}