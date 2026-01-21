import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/sp_by_addresses_api.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';


class SPByAddressController with ChangeNotifier {
  final List<ServiceProviderModel> _serviceProviders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceProviderModel> get serviceProviders => List.unmodifiable(_serviceProviders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch SPs for all visible providers on the map (bulk call)
  Future<void> fetchFromVisibleMarkers(HereMapMarkerController markerCtrl) async {
    final visibleAddresses = markerCtrl.visibleProviders;

    if (visibleAddresses.isEmpty) {
      _errorMessage = "No visible providers on map";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _serviceProviders.clear();
    notifyListeners();

    try {
      // collect all IDs
      final ids = visibleAddresses
    .map((addr) => addr.providerId)    // maybe String? or dynamic
    .where((id) => id != null)         // remove nulls
    .map((id) => id!.toString())       // ensure all are Strings
    .toList();   

      // ✅ single request with ?ids=2,1
      final spList = await ServiceProvidersByAddressApi.fetchProvidersByAddresses(ids.map(int.parse).toList());

      _serviceProviders.addAll(spList);
    } catch (e) {
      _errorMessage = "Failed to fetch providers: ${e.toString()}";
      _serviceProviders.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _serviceProviders.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
