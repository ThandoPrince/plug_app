import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';

import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_addesses_controller.dart';


class HomeRefreshController with ChangeNotifier {
  final SPByAddressController spByAddressController;
  final HereMapMarkerController mapMarkerCtrl;
  final ServiceController serviceController;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeRefreshController({
    required this.spByAddressController,
    required this.mapMarkerCtrl,
    required this.serviceController,
  });

  /// Refresh all home page data
  Future<void> refreshHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Refresh visible service providers
      await spByAddressController.fetchFromVisibleMarkers(mapMarkerCtrl);

      // 2️⃣ Refresh all services
      await serviceController.fetchServices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
