import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/client_services/address_client_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';

class AddressClientCtrl with ChangeNotifier {
  List<AddressClientModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool _hasFetchedOnce = false;

  List<AddressClientModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// ✅ Normal fetch (cached / anti-spam)
  Future<void> fetchAddresses() async {
    if (_hasFetchedOnce) return;

    await _loadAddresses();
    _hasFetchedOnce = true;
  }

  /// ✅ Forced refresh (pull-to-refresh / UI refresh)
  Future<void> refresh() async {
    await _loadAddresses();
  }

  /// ✅ Shared internal loader
  Future<void> _loadAddresses() async {
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

  /// ✅ Reset cache (use after updates like default address change)
  void resetCache() {
    _hasFetchedOnce = false;
  }

  void clearAddresses() {
    _addresses = [];
    _errorMessage = null;
    _hasFetchedOnce = false;
    notifyListeners();
  }
}