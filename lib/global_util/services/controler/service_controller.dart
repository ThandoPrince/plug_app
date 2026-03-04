import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';

import 'package:flutter_application_1/const/services/service_api.dart';

class ServiceController with ChangeNotifier {
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;


  // ServiceController() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     fetchServices();
  //   });
  // }
final List<int> _featuredServiceIds = [
  1, 2, 8, 61, 9, 12, 62, 32, 66, 25
];


  // Filtered services (currently displayed)
  List<ServiceModel> get services => _services;

  // Alias getter in case your UI uses filteredServices
  List<ServiceModel> get filteredServices => _services;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await ServiceApi.fetchServices();
      _allServices = fetched;
      _services = fetched;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterServices(String query) {
    if (query.isEmpty) {
      _services = _allServices;
    } else {
      _services = _allServices
          .where((s) => s.serviceName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
List<ServiceModel> get featuredServices {
  return _allServices
      .where((s) => _featuredServiceIds.contains(s.serviceId))
      .toList();
}
  void updateSearchQuery(String query) {
    filterServices(query);
  }

}