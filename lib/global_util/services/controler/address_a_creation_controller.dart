import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/a_address_creation_helper.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';

class AddressACreationController with ChangeNotifier {
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
  unitNumberController.dispose();
  streetNumberController.dispose();
  routeController.dispose();
  cityController.dispose();
  latitudeController.dispose();
  longitudeController.dispose();
  super.dispose();
}

  // =============================
  // SET ADDRESS FROM GOOGLE
  // =============================
  Future<void> setAddressFromPrediction(
      Prediction prediction, String apiKey) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    final detail = await places.getDetailsByPlaceId(prediction.placeId!);

    if (detail.status != "OK") {
      throw Exception(detail.errorMessage);
    }

    final result = detail.result;

    // Store actual Google place_id
    placeId = result.placeId;

    addressController.text = result.formattedAddress ?? "";

    // Clear structured fields
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

final latitude = result.geometry?.location.lat;
final longitude = result.geometry?.location.lng;

if (latitude == null || longitude == null) {
  throw Exception("Google Maps did not return valid coordinates.");
}

latitudeController.text = latitude.toStringAsFixed(7);
longitudeController.text = longitude.toStringAsFixed(7);

    notifyListeners();
  }

  // =============================
  // VALIDATION
  // =============================
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

  // =============================
  // POST ADDRESS
  // =============================
Future<Map<String, dynamic>?> postResidentialAddress() async {
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
        "latitude": _formatCoordinate(latitudeController.text),
"longitude": _formatCoordinate(longitudeController.text),
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

    final response = await AAddressCreationHelper.addClientAddress(
      data: payload,
     
    );

    debugPrint("========== ADDRESS RESPONSE ==========");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Raw Body: ${response.body}");

    if (response.body.isEmpty) {
      error = "Empty response from server.";
      return null;
    }

    final Map<String, dynamic> decodedBody =
        jsonDecode(response.body);

    final bool success = decodedBody["success"] == true;

    if (!success) {
  final errors = decodedBody["errors"];

  // Handle DRF validation errors
  if (errors is Map<String, dynamic>) {
    final nonFieldErrors = errors["non_field_errors"];

    if (nonFieldErrors is List && nonFieldErrors.isNotEmpty) {
      error = nonFieldErrors.first.toString();
    } else {
      // Handle field-specific errors
      final messages = <String>[];

      errors.forEach((field, value) {
        if (value is List) {
          for (final message in value) {
            messages.add(message.toString());
          }
        } else {
          messages.add(value.toString());
        }
      });

      if (messages.isNotEmpty) {
        error = messages.join("\n");
      }
    }
  }

  // Fallback to the normal API message
  error ??= decodedBody["message"] ??
      decodedBody["detail"] ??
      "Failed to add address";

  return null;
}

    // ✅ SUCCESS PATH
    error = null;
    return decodedBody;

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

String _formatCoordinate(String value) {
  final coordinate = double.tryParse(value);

  if (coordinate == null) {
    throw FormatException("Invalid coordinate: $value");
  }

  return coordinate.toStringAsFixed(7);
}

}
