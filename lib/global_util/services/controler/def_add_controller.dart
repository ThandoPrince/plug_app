import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/address_client_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';

class DefAddController extends ChangeNotifier {
  List<AddressClientModel> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<AddressClientModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all addresses for a client
  Future<void> fetchAddresses(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await AddressClientsApi.getAddressClients(email);
    } catch (e) {
      _error = e.toString();
      _addresses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear controller state
  void clearAddresses() {
    _addresses = [];
    _error = null;
    notifyListeners();
  }
}
