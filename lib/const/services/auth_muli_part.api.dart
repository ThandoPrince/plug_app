import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:http/http.dart' as http;

class AuthMultipartClient {
  static Future<http.StreamedResponse> sendWithRefresh(
    http.MultipartRequest request,
  ) async {
    final auth = await ApiTokensHelper.authHeaders();
    request.headers.addAll(auth);

    final response = await request.send();

    if (response.statusCode == 401) {
      final newToken =
          await AuthSessionController.instance.refreshAccessToken();

      if (newToken != null) {
        final retry = http.MultipartRequest(
          request.method,
          request.url,
        );

        retry.fields.addAll(request.fields);
        retry.files.addAll(request.files);

        retry.headers.addAll({
          ...request.headers,
          "Authorization": "Bearer $newToken",
        });

        return await retry.send();
      }
    }

    return response;
  }
}