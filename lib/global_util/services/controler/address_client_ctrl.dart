import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/client_services/address_client_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';

class AddressClientCtrl with ChangeNotifier {
  List<AddressClientModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressClientModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all addresses associated with the client
  Future<void> fetchAddresses(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await AddressClientsApi.getAddressClients();
    } catch (e) {
      _errorMessage = e.toString();
      _addresses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear controller state
  void clearAddresses() {
    _addresses = [];
    _errorMessage = null;
    notifyListeners();
  }
}
