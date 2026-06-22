import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';
import 'package:flutter_application_1/const/services/registration/client_auth_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:package_info_plus/package_info_plus.dart';



class ClientAuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
StreamSubscription<String>? _huaweiTokenSubscription;
StreamSubscription<String>? _firebaseTokenRefreshSubscription;

  bool _isLoading = false;
  String? _error;
  Map<String, String?> fieldErrors = {};

  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;
final AuthLoginApi _apiHelper = AuthLoginApi();
  // ======================
  // REGISTER
  // ======================
  // ======================
  // REGISTER
  // ======================
  Future<bool> register() async {
    _setLoading(true);
    _clearErrors();

    try {
      // ======================
      // CLIENT-SIDE VALIDATION
      // ======================
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        fieldErrors['confirmPassword'] = "Passwords do not match";
        _setLoading(false);
        notifyListeners();
        return false;
      }

      final result = await ClientAuthApi.register(
        email: emailController.text.trim().toLowerCase(),
        mobile: mobileController.text.trim(),
        password: passwordController.text.trim(),
      );

      await AuthSessionController.instance.setSession(
        clientId: result.data.id,

        accessToken: result.data.accessToken,
        refreshToken: result.data.refreshToken,
      );

      

      await _fetchAndSendPushToken();

      _isSuccess = true;
      _setLoading(false);
      return true;
    } catch (e) {
      String? rawJsonBody;

      // 1. Inspect if the error object itself exposes the response body directly
      // (Common for custom API clients or packages like Dio)
      dynamic errorObject = e;
      if (errorObject.runtimeType.toString().contains('Dio') || 
          errorObject.toString().contains('Response')) {
        try {
          rawJsonBody = errorObject.response?.data?.toString();
        } catch (_) {}
      }

      // 2. If not extracted above, find the structural JSON text inside the Exception string
      if (rawJsonBody == null) {
        final errorString = e.toString();
        final jsonStartIndex = errorString.indexOf('{');
        final jsonEndIndex = errorString.lastIndexOf('}');
        
        if (jsonStartIndex != -1 && jsonEndIndex != -1 && jsonEndIndex > jsonStartIndex) {
          rawJsonBody = errorString.substring(jsonStartIndex, jsonEndIndex + 1);
        }
      }

      // 3. Process the extracted body or fall back gracefully
      if (rawJsonBody != null) {
        final decodedMap = _safeDecode(rawJsonBody);
        if (decodedMap.isNotEmpty) {
          _handleErrors(decodedMap);
        } else {
          _error = e.toString().replaceFirst('Exception: ', '');
        }
      } else {
        _error = e.toString().replaceFirst('Exception: ', '');
      }

      _setLoading(false);
      return false;
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

  // ======================
  // Helpers
  // ======================
  Map<String, dynamic> _safeDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  void _handleErrors(Map<String, dynamic> body) {
    // 1. Start with a fresh map copy to clear old states, but preserve client-side if needed
    final errors = <String, String?>{};

    body.forEach((key, value) {
      // Convert list of messages or single string into a clean layout string
      final message = (value is List && value.isNotEmpty)
          ? value.join('\n')
          : value.toString();

      switch (key) {
        case 'email_address':
          errors['email'] = message;
          break;
        case 'mobile_number':
          errors['mobile'] = message;
          break;
        case 'password':
          errors['password'] = message;
          break;
        case 'non_field_errors':
        case 'detail':
          _error = message;
          break;
        default:
          // Catch-all for unexpected backend validation keys
          errors[key] = message;
          break;
      }
    });

    // 2. Assign the complete multi-field error map to the UI state holder
    fieldErrors = errors;
    notifyListeners(); // Force UI fields to redraw with their respective errors
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

  // ======================
  // Dispose
  // ======================
  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}