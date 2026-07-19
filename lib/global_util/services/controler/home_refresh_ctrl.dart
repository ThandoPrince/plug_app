import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/def_add_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';

import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_addesses_controller.dart';

class HomeRefreshController with ChangeNotifier {
  final SPByAddressController spByAddressController;
 
  final GoogleMapMarkerController googleMapMarkerController;
  final ServiceController serviceController;
  final DefAddController defAddController;
  final AuthSessionController authSessionController;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeRefreshController({
    required this.spByAddressController,
    required this.defAddController,

    required this.googleMapMarkerController,
    required this.serviceController,
    required this.authSessionController,
  });

  /// Refresh all home page data
  Future<void> refreshHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all data
      await defAddController.fetchAddresses();
    
      await spByAddressController
          .googlefetchFromVisibleMarkers(googleMapMarkerController);
  
      await serviceController.fetchServices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
