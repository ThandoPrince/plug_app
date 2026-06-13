import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthSessionController with ChangeNotifier {
  AuthSessionController._internal();
  static final AuthSessionController instance =
      AuthSessionController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ======================
  // Memory state
  // ======================
  String? _email;
  int? _clientId;
  String? _accessToken;
  String? _refreshToken;

  String? get email => _email;
  int? get clientId => _clientId;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isLoggedIn =>
      _accessToken?.isNotEmpty == true &&
      _refreshToken?.isNotEmpty == true;

  // ======================
  // Keys
  // ======================
  static const _kEmail = "auth_email";
  static const _kClientId = "auth_client_id";
  static const _kAccess = "auth_access_token";
  static const _kRefresh = "auth_refresh_token";

  // ======================
  // Load session on app start
  // ======================
  Future<void> loadSession() async {
    _email = await _storage.read(key: _kEmail);

    final id = await _storage.read(key: _kClientId);
    _clientId = id != null ? int.tryParse(id) : null;

    _accessToken = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);

    notifyListeners();
  }

  // ======================
  // Save session
  // ======================
  Future<void> setSession({
    required int clientId,
    required String email,
    required String accessToken,
    required String refreshToken,
  }) async {
    _clientId = clientId;
    _email = email;
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await Future.wait([
      _storage.write(key: _kClientId, value: clientId.toString()),
      _storage.write(key: _kEmail, value: email),
      _storage.write(key: _kAccess, value: accessToken),
      _storage.write(key: _kRefresh, value: refreshToken),
    ]);

    notifyListeners();
  }

  // ======================
  // Clear session (logout)
  // ======================
  Future<void> clearSession() async {
    _email = null;
    _clientId = null;
    _accessToken = null;
    _refreshToken = null;

    await _storage.deleteAll();
    notifyListeners();
  }

  Future<String?> refreshAccessToken() async {
  if (_refreshToken == null) return null;

   final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  final url = Uri.parse("$baseUrl/client/token/refresh/");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "refresh": _refreshToken,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    _accessToken = data["access"];

    await _storage.write(key: _kAccess, value: _accessToken);

    notifyListeners();
    return _accessToken;
  }

  // refresh token is invalid → force logout
  await clearSession();
  return null;
}
}