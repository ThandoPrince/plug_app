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
    Future<String?>? _refreshFuture;

  int? _clientId;
  String? _accessToken;
  String? _refreshToken;
bool _loggedOut = false;
bool get loggedOut => _loggedOut;

  int? get clientId => _clientId;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isLoggedIn =>
      _accessToken?.isNotEmpty == true &&
      _refreshToken?.isNotEmpty == true;

  // ======================
  // Keys
  // ======================

  static const _kClientId = "auth_client_id";
  static const _kAccess = "auth_access_token";
  static const _kRefresh = "auth_refresh_token";

  // ======================
  // Load session on app start
  // ======================
  Future<void> loadSession() async {
 

    final id = await _storage.read(key: _kClientId);
    _clientId = id != null ? int.tryParse(id) : null;

    _accessToken = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);

    notifyListeners();
  }

  void resetLogoutFlag() {
  _loggedOut = false;
}

Future<String?> getValidAccessToken() async {
  final token = accessToken;
  if (token == null) return null;

  // optional: decode JWT expiry check here

  final newToken = await refreshAccessToken();
  return newToken ?? token;
}

  // ======================
  // Save session
  // ======================
  Future<void> setSession({
    required int clientId,

    required String accessToken,
    required String refreshToken,
  }) async {
    _clientId = clientId;

    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await Future.wait([
      _storage.write(key: _kClientId, value: clientId.toString()),
 
      _storage.write(key: _kAccess, value: accessToken),
      _storage.write(key: _kRefresh, value: refreshToken),
    ]);

    notifyListeners();
  }

  // ======================
  // Clear session (logout)
  // ======================
  Future<void> clearSession() async {
  _clientId = null;
  _accessToken = null;
  _refreshToken = null;

  _loggedOut = true;

  await _storage.deleteAll();
  notifyListeners();
}

  Future<String?> refreshAccessToken() async {
  if (_refreshFuture != null) {
    debugPrint("Refresh already in progress. Waiting...");
    return await _refreshFuture;
  }

  _refreshFuture = _performRefresh();

  try {
    return await _refreshFuture;
  } finally {
    _refreshFuture = null;
  }
}

Future<String?> _performRefresh() async {
  if (_refreshToken == null) {
    return null;
  }

  try {
    debugPrint("Refreshing access token...");

    final String baseUrl =
        dotenv.env['API_BASE_URL'] ?? '';

    final url = Uri.parse(
      "$baseUrl/client/token/refresh/",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "refresh": _refreshToken,
      }),
    );

    debugPrint(
      "Refresh response: ${response.statusCode}",
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _accessToken = data["access"];

      if (data["refresh"] != null) {
        _refreshToken = data["refresh"];

        await _storage.write(
          key: _kRefresh,
          value: _refreshToken,
        );
      }

      await _storage.write(
        key: _kAccess,
        value: _accessToken,
      );

      notifyListeners();

      debugPrint("Token refresh successful");

      return _accessToken;
    }

    debugPrint(
      "Refresh failed: ${response.body}",
    );

    await clearSession();

    return null;
  } catch (e) {
    debugPrint(
      "Refresh exception: $e",
    );

    await clearSession();

    return null;
  }
}
}