import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/sp_add_by_service_api.dart';
import 'package:flutter_application_1/const/services/sp_address_api.dart';
import 'package:flutter_application_1/global_util/services/models/sp_address_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

class SpAddressController extends ChangeNotifier {
  List<SpAddressModel> _addresses = [];
  List<ServiceProviderModel> _linkedSPs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SpAddressModel> get addresses => _addresses;
  List<ServiceProviderModel> get linkedSPs => _linkedSPs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all SP addresses
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await AddressApi.fetchAllAddresses();
      _addresses = fetched;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch linked service providers for a list of addresses
  Future<void> fetchLinkedServiceProviders(List<SpAddressModel> addresses) async {
    if (addresses.isEmpty) return;

    _isLoading = true;
    _error = null;
    _linkedSPs = [];
    notifyListeners();

    try {
      for (final addr in addresses) {
        final sps = await SpAddByServiceApi.fetchSPsByAddress(addr.id); // API call to get SPs for each address
        _linkedSPs.addAll(sps.cast<ServiceProviderModel>());
      }
    } catch (e) {
      _error = e.toString();
      _linkedSPs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _addresses = [];
    _linkedSPs = [];
    _error = null;
    notifyListeners();
  }
}
