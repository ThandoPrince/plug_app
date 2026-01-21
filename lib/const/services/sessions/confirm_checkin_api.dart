import 'dart:convert';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_token_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ConfirmCheckinApi {
  static final ConfirmCheckinApi _instance = ConfirmCheckinApi._internal();
  factory ConfirmCheckinApi() => _instance;
  ConfirmCheckinApi._internal();

  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: _defaultHeaders(headers),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: _defaultHeaders(headers),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, String> _defaultHeaders(Map<String, String>? headers) {
    return {
      "Content-Type": "application/json",
      ...?headers,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      throw Exception(decoded["detail"] ?? "API Error");
    }
  }
}

class ClientCheckinApi {
  final ConfirmCheckinApi _api = ConfirmCheckinApi();

  Future<SessionTokenModel> fetchCheckinToken(int shipmentId) async {
    final json = await _api.get(
      "/bookings/sessions/get_checkin_token/$shipmentId",
    );

    return SessionTokenModel.fromJson(json);
  }
}