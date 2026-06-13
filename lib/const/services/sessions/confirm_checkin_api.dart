import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/api_tokens_helper.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_token_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ConfirmCheckinApi {
  static final ConfirmCheckinApi _instance = ConfirmCheckinApi._internal();
  factory ConfirmCheckinApi() => _instance;
  ConfirmCheckinApi._internal();

  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // =========================
  // GET
  // =========================
  Future<Map<String, dynamic>> get(
    String endpoint,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await ApiTokensHelper.authHeaders(),
    );

    return _handleResponse(response);
  }

  // =========================
  // POST
  // =========================
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Object? body,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await ApiTokensHelper.authHeaders(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // =========================
  // RESPONSE HANDLER
  // =========================
  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (kDebugMode) {
      print("API ${response.statusCode}: ${response.body}");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw Exception("Invalid response format (expected Map)");
    }

    String message = "API Error";

    if (decoded is Map<String, dynamic>) {
      message = decoded["detail"] ?? decoded["error"] ?? decoded.toString();
    }

    throw Exception(message);
  }
}

// =========================
// CLIENT LAYER
// =========================
class ClientCheckinApi {
  final ConfirmCheckinApi _api = ConfirmCheckinApi();

  Future<SessionTokenModel> fetchCheckinToken(int shipmentId) async {
    final json = await _api.get(
      "/bookings/sessions/get_checkin_token/$shipmentId",
    );

    return SessionTokenModel.fromJson(json);
  }
}
