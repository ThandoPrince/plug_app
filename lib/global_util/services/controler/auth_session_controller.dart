import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  static const _kIsLoggedIn = "auth_is_logged_in";
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  

  // ======================
  // Keys
  // ======================

  static const _kClientId = "auth_client_id";
  static const _kAccess = "auth_access_token";
  static const _kRefresh = "auth_refresh_token";



  // ======================
// OTP verification state
// ======================

static const _kOtpClientId = "otp_client_id";
static const _kOtpEmail = "otp_email";
static const _kOtpMobileNumber = "otp_mobile_number";
static const _kOtpRequiresEmailVerification =
    "otp_requires_email_verification";
static const _kOtpRequestId = "otp_request_id";
static const _kVerificationToken = "otp_verification_token";

int? _otpClientId;
String? _otpEmail;
String? _otpMobileNumber;
bool _otpRequiresEmailVerification = false;
String? _otpRequestId;
String? _verificationToken;

int? get otpClientId => _otpClientId;
String? get otpEmail => _otpEmail;
String? get otpMobileNumber => _otpMobileNumber;
bool get otpRequiresEmailVerification =>
    _otpRequiresEmailVerification;
String? get otpRequestId => _otpRequestId;
String? get verificationToken => _verificationToken;


Future<void> setOtpSession({
  required int clientId,
  required String email,
  required bool requiresEmailVerification,
  required String otpRequestId,
  required String verificationToken,
}) async {
  _otpClientId = clientId;
  _otpEmail = email;
  _otpRequiresEmailVerification = requiresEmailVerification;
  _otpRequestId = otpRequestId;
  _verificationToken = verificationToken;

  await Future.wait([
    _storage.write(
      key: _kOtpClientId,
      value: clientId.toString(),
    ),
    _storage.write(
      key: _kOtpEmail,
      value: email,
    ),
    _storage.write(
      key: _kOtpRequiresEmailVerification,
      value: requiresEmailVerification.toString(),
    ),
    _storage.write(
      key: _kOtpRequestId,
      value: otpRequestId,
    ),
    _storage.write(
      key: _kVerificationToken,
      value: verificationToken,
    ),
  ]);

  notifyListeners();
}

  // ======================
  // Load session on app start
  // ======================
  Future<void> loadSession() async {
 

    final id = await _storage.read(key: _kClientId);
    _clientId = id != null ? int.tryParse(id) : null;

    _accessToken = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);
    final storedLoggedIn =
      await _storage.read(key: _kIsLoggedIn);

  _isLoggedIn = storedLoggedIn == 'true';
  _loggedOut = !_isLoggedIn;

  final otpClientId =
    await _storage.read(key: _kOtpClientId);

_otpClientId =
    otpClientId != null ? int.tryParse(otpClientId) : null;

_otpEmail = await _storage.read(key: _kOtpEmail);

_otpMobileNumber =
    await _storage.read(key: _kOtpMobileNumber);

final requiresEmailVerification =
    await _storage.read(
      key: _kOtpRequiresEmailVerification,
    );

_otpRequiresEmailVerification =
    requiresEmailVerification == 'true';

_otpRequestId =
    await _storage.read(key: _kOtpRequestId);

_verificationToken =
    await _storage.read(key: _kVerificationToken);

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
// Update verification token (used after OTP resend)
// ======================
Future<void> updateVerificationToken(
  String verificationToken, {
  String? otpRequestId,
}) async {
  _verificationToken = verificationToken;

  final writes = <Future>[
    _storage.write(
      key: _kVerificationToken,
      value: verificationToken,
    ),
  ];

  if (otpRequestId != null) {
    _otpRequestId = otpRequestId;
    writes.add(
      _storage.write(
        key: _kOtpRequestId,
        value: otpRequestId,
      ),
    );
  }

  await Future.wait(writes);

  notifyListeners();
}


Future<void> clearOtpSession() async {
  _otpClientId = null;
  _otpEmail = null;
  _otpMobileNumber = null;
  _otpRequiresEmailVerification = false;
  _otpRequestId = null;
  _verificationToken = null;

  await Future.wait([
    _storage.delete(key: _kOtpClientId),
    _storage.delete(key: _kOtpEmail),
    _storage.delete(key: _kOtpMobileNumber),
    _storage.delete(
      key: _kOtpRequiresEmailVerification,
    ),
    _storage.delete(key: _kOtpRequestId),
    _storage.delete(key: _kVerificationToken),
  ]);

  notifyListeners();
}

Future<void> setLoggedIn(bool value) async {
  _isLoggedIn = value;
  _loggedOut = !value;

  await _storage.write(
    key: _kIsLoggedIn,
    value: value.toString(),
  );

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

  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final url = Uri.parse("$baseUrl/client/token/refresh/");

  http.Response response;
  try {
    debugPrint("Refreshing access token...");

    response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"refresh": _refreshToken}),
        )
        .timeout(const Duration(seconds: 15));
  } on SocketException catch (e) {
    // No internet / server unreachable — NOT an auth failure.
    debugPrint("Refresh network error (no connection): $e");
    rethrow;
  } on TimeoutException catch (e) {
    debugPrint("Refresh timed out: $e");
    rethrow;
  } catch (e) {
    // Truly unexpected (bad URL, parsing, etc.) — don't silently log out either.
    debugPrint("Refresh unexpected error: $e");
    rethrow;
  }

  debugPrint("Refresh response: ${response.statusCode}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    _accessToken = data["access"];

    if (data["refresh"] != null) {
      _refreshToken = data["refresh"];
      await _storage.write(key: _kRefresh, value: _refreshToken);
    }

    await _storage.write(key: _kAccess, value: _accessToken);
    notifyListeners();
    debugPrint("Token refresh successful");
    return _accessToken;
  }

  // Server responded and said the refresh token is invalid/expired.
  // THIS is the only case that should clear the session.
  debugPrint("Refresh rejected by server: ${response.statusCode} ${response.body}");
  await clearSession();
  return null;
}
}