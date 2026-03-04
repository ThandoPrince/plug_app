

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/default_address_patch_api.dart';


class PatchDefaultAddressController with ChangeNotifier {
  final DefaultAddressPatchApi apiHelper =DefaultAddressPatchApi();
  bool isLoading = false;

  

  /// Set selected address as default
  Future<void> setDefault(int addressId, String email) async {
    isLoading = true;
    notifyListeners();

    final success = await apiHelper.setDefaultAddress(addressId: addressId, email: email);

    if (success) {
      // Optionally update local state if you have a list of addresses
      if (kDebugMode) {
        print('Address $addressId is now default.');
      }
    } else {
      if (kDebugMode) {
        print('Failed to update default address.');
      }
    }

    isLoading = false;
    notifyListeners();
  }
}