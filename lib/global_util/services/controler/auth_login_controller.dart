import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginController extends ChangeNotifier {
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  static LoginController get instance => _instance;

  LoginController._internal() {
    emailController.addListener(_clearEmailError);
    passwordController.addListener(_clearPasswordError);
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _generalError;
  String? get generalError => _generalError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  final AuthLoginApi _apiHelper = AuthLoginApi();

  StreamSubscription<String>? _huaweiTokenSubscription;
  StreamSubscription<String>? _firebaseTokenRefreshSubscription;

  Future<bool> login() async {
    _startLoading();
    _clearAllErrors();

    if (!_validateInputs()) {
      _stopLoading();
      return false;
    }

    try {
      final result = await _apiHelper.login(
        identifier: emailController.text.trim().toString(),
        password: passwordController.text.trim(),
      );

      if (result.id == null ||
          result.accessToken == null ||
          result.refreshToken == null) {
        _generalError = "Incomplete login response";
        return false;
      }

      final clientId = result.id;
      if (clientId == null) {
        _generalError = 'Login response missing client id';
        return false;
      }

      // ✅ SESSION
      await AuthSessionController.instance.setSession(
        clientId: clientId,
       
        accessToken: result.accessToken.toString(),
        refreshToken: result.refreshToken.toString(),
      );



      await _fetchAndSendPushToken();

      _userData = {
        "id": clientId,
        "email": result.email.toString(),
      };
      return true;
    } on ApiException catch (e) {
      _handleBackendErrors(
        e.statusCode,
        e.data,
      );
      return false;
    } catch (e) {
      _generalError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<void> _fetchAndSendPushToken() async {
    if (!Platform.isAndroid) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    try {
      if (isHuaweiDevice) {
        if (kDebugMode) print("Huawei device detected → using Huawei Push");

        await _huaweiTokenSubscription?.cancel();

        _huaweiTokenSubscription = Push.getTokenStream.listen(
          (String token) async {
            if (token.isEmpty) return;

            if (kDebugMode) print("Huawei Push Token: $token");

            final result = await _apiHelper.updatePushToken(
              
              token: token,
              provider: 'huawei',
              deviceType: deviceInfo['deviceType'],
              deviceName: deviceInfo['deviceName'],
              osVersion: deviceInfo['osVersion'],
              appVersion: appVersion,
            );

            if (result['statusCode'] != 200) {
              if (kDebugMode) {
                print(
                  "Huawei push token registration FAILED: "
                  "${result['statusCode']} → ${result['data']}",
                );
              }
            } else {
              if (kDebugMode) {
                print("Huawei push token registered successfully");
              }
            }
          },
          onError: (e) {
            if (kDebugMode) print("Huawei token stream error: $e");
          },
        );

        Push.getToken("HCM");
        return;
      }

      if (kDebugMode) print("Google device detected → using Firebase");

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        if (kDebugMode) print("Firebase Token: $token");

        final result = await _apiHelper.updatePushToken(
      
          token: token,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (result['statusCode'] != 200 && result['statusCode'] != 201) {
          if (kDebugMode) {
            print(
              "Firebase push token registration FAILED: "
              "${result['statusCode']} → ${result['data']}",
            );
          }
        } else {
          if (kDebugMode) {
            print("Firebase push token registered successfully");
          }
        }
      } else {
        if (kDebugMode) print("Firebase token is null or empty");
      }

      await _firebaseTokenRefreshSubscription?.cancel();
      _firebaseTokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) print("Firebase Token Refreshed: $newToken");

        final result = await _apiHelper.updatePushToken(
        
          token: newToken,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (kDebugMode) {
          print("Firebase refreshed token registration result: $result");
        }
      });
    } catch (e) {
      if (kDebugMode) print("Push token error: $e");
    }
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    String deviceType = Platform.isAndroid ? 'android' : 'ios';
    String deviceName = '';
    String osVersion = '';

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = androidInfo.model;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceName = iosInfo.name;
        osVersion = iosInfo.systemVersion;
      }
    } catch (e) {
      if (kDebugMode) print("Device info error: $e");
    }

    return {
      'deviceType': deviceType,
      'deviceName': deviceName,
      'osVersion': osVersion,
    };
  }

  Future<String> _getAppVersion() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (e) {
      if (kDebugMode) {
        print("App version error: $e");
      }
      return '';
    }
  }

  bool _validateInputs() {
    final identifier = emailController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty) {
      _emailError = "Email or mobile number is required.";
    }

    if (password.isEmpty) {
      _passwordError = "Password is required.";
    }

    if (_emailError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[\w\-]{2,4}$');

    final mobileRegex = RegExp(r'^(?:\+27|27|0)[6-8][0-9]{8}$');

    final isEmail = identifier.contains('@');
    final isMobile = RegExp(r'^\+?\d+$').hasMatch(identifier);

    if (isEmail) {
      if (!emailRegex.hasMatch(identifier)) {
        _emailError = "Enter a valid email address.";
        notifyListeners();
        return false;
      }
    } else if (isMobile) {
      if (!mobileRegex.hasMatch(identifier)) {
        _emailError = "Enter a valid mobile number.";
        notifyListeners();
        return false;
      }
    } else {
      _emailError = "Enter a valid email address or mobile number.";
      notifyListeners();
      return false;
    }

    return true;
  }

  void _handleBackendErrors(int statusCode, dynamic data) {
  if (data is! Map<String, dynamic>) {
    _generalError = "Login failed.";
    notifyListeners();
    return;
  }

  final errors = data['errors'];

  if (errors is Map<String, dynamic>) {

    // -------------------------
    // Field-specific errors
    // -------------------------
    if (errors.containsKey('email')) {
      _emailError = (errors['email'] as List).join('\n');
    }

    if (errors.containsKey('identifier')) {
      _emailError = (errors['identifier'] as List).join('\n');
    }

    if (errors.containsKey('password')) {
      _passwordError = (errors['password'] as List).join('\n');
    }

    if (errors.containsKey('non_field_errors')) {
      _generalError = (errors['non_field_errors'] as List).join('\n');
    }

    // -------------------------
    // META handling (NEW)
    // -------------------------
    if (errors.containsKey('meta')) {
      final meta = errors['meta'];

      if (meta is Map<String, dynamic>) {
        final remainingAttempts = meta['remaining_attempts'];

        if (remainingAttempts != null) {
          _generalError =
              "${_generalError ?? 'Invalid credentials.'} "
              "($remainingAttempts attempts remaining)";
        }
      }
    }
  }

  _generalError ??= data['message'] ?? data['error'] ?? "Login failed.";

  notifyListeners();
}

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _clearAllErrors() {
    _generalError = null;
    _emailError = null;
    _passwordError = null;
  }

  void _clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  void _clearPasswordError() {
    if (_passwordError != null) {
      _passwordError = null;
      notifyListeners();
    }
  }

  void clear() {
    emailController.clear();
    passwordController.clear();
    _generalError = null;
    _emailError = null;
    _passwordError = null;
    _userData = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearSensitiveFields() {
    passwordController.clear();
    _passwordError = null;
    _generalError = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _huaweiTokenSubscription?.cancel();
    _firebaseTokenRefreshSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
