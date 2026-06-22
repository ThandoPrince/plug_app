import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/backend_error_handler.dart';
import 'package:flutter_application_1/const/services/registration/address_creation_helper.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';


class AddressCreationController with ChangeNotifier {
  bool isLoading = false;
  String? error;
  ApiError? apiError;
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
        
      );

      debugPrint("========== ADDRESS RESPONSE ==========");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Raw Body: ${response.body}");

      // Replace your existing response parsing section with this:
      Map<String, dynamic>? decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodedBody != null && decodedBody['success'] == true) {
          return decodedBody;
        }
      }

      // Handle structural Django Rest Framework validation maps gracefully
     if (decodedBody != null) {
  apiError = _parseError(decodedBody);

  error = apiError?.general ??
    (apiError!.fieldErrors.isNotEmpty
        ? apiError!.fieldErrors.values.first
        : "Failed to process request.");

  debugPrint("GENERAL ERROR: ${apiError?.general}");
  debugPrint("FIELD ERRORS: ${apiError?.fieldErrors}");
} else {
  error = "Failed to add address (Status: ${response.statusCode})";
}

      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



 
ApiError _parseError(Map<String, dynamic> json) {
  String? general;
  final Map<String, String> fieldErrors = {};

  // ---- GLOBAL ERRORS
  if (json.containsKey("non_field_errors")) {
    final v = json["non_field_errors"];
    if (v is List && v.isNotEmpty) {
      general = v.first.toString();
    } else {
      general = v.toString();
    }
  }

  if (json.containsKey("detail")) {
    general ??= json["detail"].toString();
  }

  if (json.containsKey("message")) {
    general ??= json["message"].toString();
  }

  if (json.containsKey("error")) {
    general ??= json["error"].toString();
  }

  // ---- FIELD ERRORS (FLATTEN ALL LEVELS)
  json.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      fieldErrors[key] = value.first.toString();
    }

    if (value is Map) {
      value.forEach((k, v) {
        if (v is List && v.isNotEmpty) {
          fieldErrors[k] = v.first.toString();
        } else {
          fieldErrors[k] = v.toString();
        }
      });
    }
  });

  return ApiError(
    general: general,
    fieldErrors: fieldErrors,
  );
}
  

  
}
extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
} 