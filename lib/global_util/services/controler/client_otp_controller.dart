import 'dart:async';

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/const/services/registration/client_otp_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';
class ClientOtpController extends ChangeNotifier {
  // =========================
  // STATE
  // =========================
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
  // VERIFY OTP
  // =========================

  Future<bool> verifyOtp({
  required String otp,
}) async {
  if (_isLoading) {
    return false;
  }

  _clearErrors();

  final cleanedOtp = otp.trim();

  // =========================
  // CLIENT VALIDATION
  // =========================

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
    final response = await ClientOtpApi.verifyOtp(
      otp: cleanedOtp,
    );

    // Extract payload from "data" wrapper if present, else fallback to root map
    final payload = (response['data'] is Map<String, dynamic>) 
        ? response['data'] as Map<String, dynamic>
        : response;

    // Safely extract token & client data
    final clientId = int.tryParse(
      payload['id']?.toString() ?? payload['client_id']?.toString() ?? '',
    );
    final accessToken = payload['access_token']?.toString() ?? payload['accessToken']?.toString() ?? '';
    final refreshToken = payload['refresh_token']?.toString() ?? payload['refreshToken']?.toString() ?? '';

    if (clientId == null) {
      throw Exception("Invalid response: Missing client ID.");
    }

    if (accessToken.isEmpty) {
      throw Exception("Invalid response: Missing access token.");
    }

    await AuthSessionController.instance.setSession(
      clientId: clientId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    if (kDebugMode) {
      print("OTP verification successful.");
      print("OTP response: $response");
    }
    
    await _fetchAndSendPushToken();

    _isSuccess = true;

    return true;
  } catch (e) {
    final message = e.toString().replaceFirst(
      'Exception: ',
      '',
    );

    _error = message;

    if (kDebugMode) {
      print("OTP verification failed: $message");
    }

    return false;
  } finally {
    _setLoading(false);
  }
}

  Future<bool> resendOtp() async {
  if (_isLoading) return false;

  _clearErrors();
  _setLoading(true);

  try {
    final response = await ClientOtpApi.resendOtp();

    if (kDebugMode) {
      print("OTP resend successful.");
      print("Resend response: $response");
    }

    return true;
  } catch (e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    _error = message;

    if (kDebugMode) print("OTP resend failed: $message");

    return false;
  } finally {
    _setLoading(false);
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

        final result = await _apiHelper.updatePushToken (
          
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

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError() {
    _error = null;
    fieldErrors = {};
    notifyListeners();
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _isLoading = false;
    _isSuccess = false;
    _error = null;
    fieldErrors = {};

    notifyListeners();
  }

  // =========================
  // INTERNAL STATE
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _error = null;
    fieldErrors = {};
    _isSuccess = false;
  }
}