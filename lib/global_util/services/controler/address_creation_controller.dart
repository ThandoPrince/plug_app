import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/address_creation_helper.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';


class AddressCreationController with ChangeNotifier {
  bool isLoading = false;
  String? error;

  // Controllers
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

  Future<void> setAddressFromPrediction(
      Prediction prediction, String apiKey) async {

    final places = GoogleMapsPlaces(apiKey: apiKey);
    final detail =
        await places.getDetailsByPlaceId(prediction.placeId!);

    if (detail.status != "OK") {
      throw Exception(detail.errorMessage);
    }

    final result = detail.result;

    // Set place id
    final String? placeId = result.placeId;

    // Full formatted address
    addressController.text = result.formattedAddress ?? "";



    // Clear fields
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

      // Optional SA township support
      if (types.contains('sublocality') &&
          cityController.text.isEmpty) {
        cityController.text = component.longName;
      }
    }

    latitudeController.text =
        result.geometry?.location.lat.toString() ?? "";

    longitudeController.text =
        result.geometry?.location.lng.toString() ?? "";

    notifyListeners();
  }

  bool get isValidAddress {
  return streetNumberController.text.trim().isNotEmpty &&
         routeController.text.trim().isNotEmpty &&
         cityController.text.trim().isNotEmpty &&
         latitudeController.text.trim().isNotEmpty &&
         longitudeController.text.trim().isNotEmpty;
}


  Future<bool> postResidentialAddress(String email) async {

    if (!isValidAddress) {
    error = "Please select a complete street address.";
    notifyListeners();
    return false;
  }
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final payload = {
        "address": {
          "place_id": streetNumberController.text.isNotEmpty
              ? addressController.text
              : null,
          "formatted_address": addressController.text.trim(),
          "street_number": streetNumberController.text.trim(),
          "route": routeController.text.trim(),
          "locality": cityController.text.trim(),
          "administrative_area_level_1":
              stateController.text.trim(),
          "country": countryController.text.trim(),
          "postal_code": postalCodeController.text.trim(),
          "latitude": double.tryParse(latitudeController.text),
          "longitude": double.tryParse(longitudeController.text),
        },
        "is_owner": isOwner,
        "is_default": isDefault,
        "address_type": "Residential Address",
      };

      final response =
          await AddressCreationHelper.addClientAddress(
        data: payload,
        email: email,
      );

      if (response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        error = data['error'] ?? "Failed to add address";
      }
    } catch (e) {
      error = "An error occurred: $e";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
