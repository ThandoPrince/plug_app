import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';

import 'package:flutter_application_1/const/services/service_api.dart';

class ServiceController with ChangeNotifier {
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  final List<int> _featuredServiceIds = [
    1, 2, 3, 29, 16, 20, 46, 15, 6, 4
  ];

  List<ServiceModel> get services => _services;
  List<ServiceModel> get filteredServices => _services;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchServices() async {
    // Already loaded -> don't fetch again
    if (_allServices.isNotEmpty) return;

    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await ServiceApi.fetchServices();
      _allServices = fetched;
      _services = fetched;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _allServices.clear();
    _services.clear();
    _error = null;
    notifyListeners();
  }

  void filterServices(String query) {
    if (query.isEmpty) {
      _services = List.from(_allServices);
    } else {
      _services = _allServices.where((s) {
        return s.serviceName
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
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