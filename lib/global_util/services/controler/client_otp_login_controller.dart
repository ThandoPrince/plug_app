import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';
import 'package:flutter_application_1/const/services/registration/login_otp_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class LoginOtpController extends ChangeNotifier {
  final AuthLoginApi _apiHelper = AuthLoginApi();

  bool _isLoading = false;
  bool _isSuccess = false;
  StreamSubscription<String>? _huaweiTokenSubscription;
  StreamSubscription<String>? _firebaseTokenRefreshSubscription;

  String? _error;
  Map<String, String?> fieldErrors = {};

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get error => _error;

  // =========================
  // VERIFY LOGIN OTP  (this is the fix: session is now set here)
  // =========================
  Future<bool> verifyOtp({required String otp}) async {
    if (_isLoading) return false;

    _clearErrors();

    final cleanedOtp = otp.trim();

    if (cleanedOtp.isEmpty) {
      fieldErrors["otp"] = "Please enter the OTP.";
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanedOtp)) {
      fieldErrors["otp"] = "OTP must contain numbers only.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      final result = await LoginOtpApi.verifyLoginOtp(otp: cleanedOtp);

      if (result.id == null ||
          result.accessToken == null ||
          result.refreshToken == null) {
        _error = "Incomplete login response";
        return false;
      }

      // ✅ SESSION — this is the step that was missing before.
      await AuthSessionController.instance.setSession(
        clientId: result.id!,
        accessToken: result.accessToken.toString(),
        refreshToken: result.refreshToken.toString(),
      );

      await _fetchAndSendPushToken();

      if (kDebugMode) print("Login OTP verification successful.");

      _isSuccess = true;
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      _error = message;
      if (kDebugMode) print("Login OTP verification failed: $message");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // RESEND
  // =========================
  Future<bool> resendOtp() async {
    if (_isLoading) return false;

    _clearErrors();
    _setLoading(true);

    try {
      await LoginOtpApi.resendLoginOtp();
      if (kDebugMode) print("Login OTP resend successful.");
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      _error = message;
      if (kDebugMode) print("Login OTP resend failed: $message");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // PUSH TOKEN (same pattern as the rest of the app)
  // =========================
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
            await _apiHelper.updatePushToken(
              token: token,
              provider: 'huawei',
              deviceType: deviceInfo['deviceType'],
              deviceName: deviceInfo['deviceName'],
              osVersion: deviceInfo['osVersion'],
              appVersion: appVersion,
            );
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
        await _apiHelper.updatePushToken(
          token: token,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );
      }

      await _firebaseTokenRefreshSubscription?.cancel();
      _firebaseTokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _apiHelper.updatePushToken(
          token: newToken,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );
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
      if (kDebugMode) print("App version error: $e");
      return '';
    }
  }

  void clearError() {
    _error = null;
    fieldErrors = {};
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isSuccess = false;
    _error = null;
    fieldErrors = {};
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _error = null;
    fieldErrors = {};
    _isSuccess = false;
  }

  @override
  void dispose() {
    _huaweiTokenSubscription?.cancel();
    _firebaseTokenRefreshSubscription?.cancel();
    super.dispose();
  }
}