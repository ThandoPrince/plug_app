import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/client_services/client_address_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart';

class AddressController with ChangeNotifier {
  List<ClientAddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  int? _defaultAddressId;

  List<ClientAddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get defaultAddressId => _defaultAddressId;


Future<void> fetchClientAddresses(String email) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  

  try {
    
    _addresses = await AddressApi.getClientAddresses();

 
  } catch (e) {
    _errorMessage = e.toString();
    _addresses = [];
    _defaultAddressId = null;
  }

  _isLoading = false;
  notifyListeners();
}


  /// Set default address and notify listeners
  void setDefaultAddress(int addressId) {
    _defaultAddressId = addressId;
    notifyListeners();

    // TODO: Optionally save default to backend or local storage here
  }

  void clearAddresses() {
    _addresses = [];
    _defaultAddressId = null;
    notifyListeners();
  }
}