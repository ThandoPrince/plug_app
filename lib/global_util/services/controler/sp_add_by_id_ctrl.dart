import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/sp_add_by_service_api.dart';
import 'package:flutter_application_1/global_util/services/models/sp_live_location_model.dart';


class SpAddressControllerByID with ChangeNotifier {
  List<SPLiveLocationModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SPLiveLocationModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch addresses for a given service ID
  Future<void> fetchAddressesByService(int serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await SpAddByServiceApi.fetchSPsByAddress(serviceId);
    } catch (e) {
      _errorMessage = e.toString();
      _addresses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear addresses from controller
  void clear() {
    _addresses = [];
    _errorMessage = null;
    notifyListeners();
  }
}
