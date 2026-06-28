import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/default_address_patch_api.dart';

class PatchDefaultAddressController with ChangeNotifier {
  final DefaultAddressPatchApi apiHelper = DefaultAddressPatchApi();

  bool isLoading = false;
  String? errorMessage;

  Future<void> setDefault(int addressId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await apiHelper.setDefaultAddress(
      addressId: addressId,
    );

    if (!success) {
      errorMessage = "Unable to update default address. Please try again.";
    }

    if (kDebugMode) {
      print(success
          ? 'Address $addressId set as default.'
          : 'Failed to update default address.');
    }

    isLoading = false;
    notifyListeners();
  }
}