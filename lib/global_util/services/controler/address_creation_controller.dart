import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/address_creation_helper.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AddressCreationController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  String buildingType = "house";

  final TextEditingController unitNumberController = TextEditingController();
  final TextEditingController accessNotesController = TextEditingController();
  String addressType = "Residential Address";

  bool isHouseAdministrator = false;
  String? placeId;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  bool isOwner = false;
  bool isDefault = true;

  StreamSubscription<String>? _huaweiTokenSubscription;
  StreamSubscription<String>? _firebaseTokenRefreshSubscription;

  AddressCreationController() {
    unitNumberController.addListener(_onFieldChanged);
    streetNumberController.addListener(_onFieldChanged);
    routeController.addListener(_onFieldChanged);
    cityController.addListener(_onFieldChanged);
    latitudeController.addListener(_onFieldChanged);
    longitudeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _huaweiTokenSubscription?.cancel();
    _firebaseTokenRefreshSubscription?.cancel();

    unitNumberController.dispose();
    accessNotesController.dispose();
    addressController.dispose();
    streetNumberController.dispose();
    routeController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> setAddressFromPrediction(
    Prediction prediction,
    String apiKey,
  ) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    final detail = await places.getDetailsByPlaceId(prediction.placeId!);

    if (detail.status != "OK") {
      throw Exception(detail.errorMessage);
    }

    final result = detail.result;

    placeId = result.placeId;
    addressController.text = result.formattedAddress ?? "";

    streetNumberController.clear();
    routeController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    postalCodeController.clear();

    for (final component in result.addressComponents) {
      final types = component.types;

      if (types.contains('street_number')) {
        streetNumberController.text = component.longName;
      }

      if (types.contains('route')) {
        routeController.text = component.longName;
      }

      if (types.contains('locality')) {
        cityController.text = component.longName;
      }

      if (types.contains('administrative_area_level_1')) {
        stateController.text = component.longName;
      }

      if (types.contains('country')) {
        countryController.text = component.longName;
      }

      if (types.contains('postal_code')) {
        postalCodeController.text = component.longName;
      }

      if (types.contains('sublocality') && cityController.text.isEmpty) {
        cityController.text = component.longName;
      }
    }

    latitudeController.text = result.geometry?.location.lat.toString() ?? "";
    longitudeController.text = result.geometry?.location.lng.toString() ?? "";

    notifyListeners();
  }

  bool get isValidAddress {
    final basicValid = streetNumberController.text.trim().isNotEmpty &&
        routeController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        latitudeController.text.trim().isNotEmpty &&
        longitudeController.text.trim().isNotEmpty;

    if (!basicValid) return false;

    if (buildingType == "apartment") {
      return unitNumberController.text.trim().isNotEmpty;
    }

    return true;
  }

  Future<Map<String, dynamic>?> postResidentialAddress(String email) async {
    if (!isValidAddress) {
      error = "Please select a complete street address.";
      notifyListeners();
      return null;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final payload = {
        "address": {
          "place_id": placeId,
          "formatted_address": addressController.text.trim(),
          "street_number": streetNumberController.text.trim(),
          "route": routeController.text.trim(),
          "locality": cityController.text.trim(),
          "administrative_area_level_1": stateController.text.trim(),
          "country": countryController.text.trim(),
          "postal_code": postalCodeController.text.trim(),
          "latitude": double.parse(latitudeController.text),
          "longitude": double.parse(longitudeController.text),
          "building_type": buildingType,
          "unit_number": unitNumberController.text.trim(),
          "access_notes": accessNotesController.text.trim(),
        },
        "is_owner": isOwner,
        "is_default": isDefault,
        "house_administrator": isHouseAdministrator,
        "address_type": addressType,
      };

      debugPrint("========== ADDRESS REQUEST ==========");
      debugPrint(jsonEncode(payload));

      final response = await AddressCreationHelper.addClientAddress(
        data: payload,
        email: email,
      );

      debugPrint("========== ADDRESS RESPONSE ==========");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Raw Body: ${response.body}");

      Map<String, dynamic>? decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }

      

      error = decodedBody?['error'] ??
          decodedBody?['detail'] ??
          "Failed to add address";

      return null;
    } catch (e, stack) {
      debugPrint("========== EXCEPTION ==========");
      debugPrint(e.toString());
      debugPrint(stack.toString());
      error = "An unexpected error occurred.";
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAndSendPushToken(String email) async {
    if (!Platform.isAndroid) return;

    final deviceInfo = await _getDeviceInfo();
    final appVersion = await _getAppVersion();

    try {
      if (isHuaweiDevice) {
        if (kDebugMode) {
          print("Huawei device detected → using Huawei Push");
        }

        await _huaweiTokenSubscription?.cancel();

        _huaweiTokenSubscription = Push.getTokenStream.listen(
          (String token) async {
            if (token.isEmpty) return;

            if (kDebugMode) {
              print("Huawei Push Token: $token");
            }

            final response = await AddressCreationHelper.updatePushToken(
              email: email,
              token: token,
              provider: 'huawei',
              deviceType: deviceInfo['deviceType'],
              deviceName: deviceInfo['deviceName'],
              osVersion: deviceInfo['osVersion'],
              appVersion: appVersion,
            );

            if (kDebugMode) {
              print("Huawei push token response: ${response.statusCode} ${response.body}");
            }
          },
          onError: (e) {
            if (kDebugMode) {
              print("Huawei token stream error: $e");
            }
          },
        );

        Push.getToken("HCM");
        return;
      }

      if (kDebugMode) {
        print("Google device detected → using Firebase");
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        if (kDebugMode) {
          print("Firebase Token: $token");
        }

        final response = await AddressCreationHelper.updatePushToken(
          email: email,
          token: token,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (kDebugMode) {
          print("Firebase push token response: ${response.statusCode} ${response.body}");
        }
      } else {
        if (kDebugMode) {
          print("Firebase token is null or empty");
        }
      }

      await _firebaseTokenRefreshSubscription?.cancel();
      _firebaseTokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          print("Firebase Token Refreshed: $newToken");
        }

        final response = await AddressCreationHelper.updatePushToken(
          email: email,
          token: newToken,
          provider: 'firebase',
          deviceType: deviceInfo['deviceType'],
          deviceName: deviceInfo['deviceName'],
          osVersion: deviceInfo['osVersion'],
          appVersion: appVersion,
        );

        if (kDebugMode) {
          print("Firebase refreshed token response: ${response.statusCode} ${response.body}");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Push token error: $e");
      }
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
      if (kDebugMode) {
        print("Device info error: $e");
      }
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
}