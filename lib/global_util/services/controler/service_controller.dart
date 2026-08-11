
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';
import 'package:flutter_application_1/const/services/service_api.dart';

class ServiceController with ChangeNotifier {
  List _allServices = [];
  List _services = [];

  bool _isLoading = false;
  String? _error;

  // Keep the current search text in the controller.
  String _searchQuery = '';

  final List _featuredServiceIds = [
    1,
    2,
    3,
    29,
    16,
    20,
    46,
    15,
    6,
    4,
  ];

  List get services => _services;

  List get filteredServices => _services;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String get searchQuery => _searchQuery;

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

      // Restore the existing search filter after refresh.
      if (_searchQuery.trim().isEmpty) {
        _services = List.from(_allServices);
      } else {
        _applySearchFilter();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterServices(String query) {
    _searchQuery = query;

    _applySearchFilter();

    notifyListeners();
  }

  void _applySearchFilter() {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      _services = List.from(_allServices);
      return;
    }

    _services = _allServices.where((service) {
      return service.serviceName
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    filterServices(query);
  }

  void clearSearch() {
    _searchQuery = '';
    _services = List.from(_allServices);

    notifyListeners();
  }

  void clear() {
    _allServices.clear();
    _services.clear();
    _searchQuery = '';
    _error = null;

    notifyListeners();
  }

  List get featuredServices {
    return _allServices
        .where(
          (service) =>
              _featuredServiceIds.contains(service.serviceId),
        )
        .toList();
  }
}

