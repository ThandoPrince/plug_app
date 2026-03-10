import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/main.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginController extends ChangeNotifier {
  /// ---------------- Singleton ----------------
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  static LoginController get instance => _instance;

  LoginController._internal() {
    emailController.addListener(_clearEmailError);
    passwordController.addListener(_clearPasswordError);
  }

  /// ---------------- Controllers ----------------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// ---------------- State ----------------
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

  /// ---------------------------------------------------------
  /// LOGIN
  /// ---------------------------------------------------------
  Future<bool> login() async {
    _startLoading();
    _clearAllErrors();

    if (!_validateInputs()) {
      _stopLoading();
      return false;
    }

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (kDebugMode) {
        print("POST DATA: {'email': '$email', 'password': '$password'}");
      }

      final response = await _apiHelper.login(
        email: email,
        password: password,
      );

      if (response['statusCode'] != 200) {
        _handleBackendErrors(response['statusCode'], response['data']);
        return false;
      }

      _userData = response['data'];

      if (_userData?['email'] != null) {
        await AuthSessionController.instance.setSession(_userData!['email']);

        if (kDebugMode) {
          print("Session set for ${_userData!['email']}");
        }

        /// Register push token
        await _fetchAndSendPushToken(_userData!['email']);
      }

      return true;
    } catch (e) {
      _generalError = "Unable to connect to the server: $e";
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// ---------------------------------------------------------
  /// PUSH TOKEN HANDLER
  /// ---------------------------------------------------------
  Future<void> _fetchAndSendPushToken(String email) async {
    if (!Platform.isAndroid) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    try {
      // ---------------- Huawei Devices ----------------
      if (isHuaweiDevice) {
        if (kDebugMode) print("Huawei device detected → using Huawei Push");

        await _huaweiTokenSubscription?.cancel();

        _huaweiTokenSubscription = Push.getTokenStream.listen(
          (String token) async {
            if (token.isEmpty) return;

            if (kDebugMode) print("Huawei Push Token: $token");

            final result = await _apiHelper.updatePushToken(
              email: email,
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

      // ---------------- Google Devices ----------------
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
          email: email,
          token: token,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (result['statusCode'] != 200 || result['statusCode'] != 201) {
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
          email: email,
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

  /// ---------------------------------------------------------
  /// DEVICE INFO
  /// ---------------------------------------------------------
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

  /// ---------------------------------------------------------
  /// APP VERSION
  /// ---------------------------------------------------------
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

  /// ---------------------------------------------------------
  /// VALIDATION
  /// ---------------------------------------------------------
  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) _emailError = "Email is required.";
    if (password.isEmpty) _passwordError = "Password is required.";

    if (_emailError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(email)) {
      _emailError = "Invalid email format.";
      notifyListeners();
      return false;
    }

    return true;
  }

  void _handleBackendErrors(int statusCode, dynamic data) {
    if (statusCode == 400 && data is Map<String, dynamic>) {
      if (data.containsKey('email')) {
        _emailError = (data['email'] as List).join("\n");
      } else if (data.containsKey('password')) {
        _passwordError = (data['password'] as List).join("\n");
      } else if (data.containsKey('non_field_errors')) {
        _generalError = (data['non_field_errors'] as List).join("\n");
      } else {
        _generalError = data['error'] ?? "Login failed.";
      }
    } else {
      _generalError = "Unexpected server error. Please try again.";
    }

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

  @override
  void dispose() {
    _huaweiTokenSubscription?.cancel();
    _firebaseTokenRefreshSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}