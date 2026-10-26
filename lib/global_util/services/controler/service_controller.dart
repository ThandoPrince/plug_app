import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/service_api.dart';

class ServiceController with ChangeNotifier {
  List _allServices = [];
  List _services = [];

  bool _isLoading = false;
  String? _error;
  
  // Track active query to prevent race conditions
  String _activeSearchQuery = '';
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
    if (_allServices.isNotEmpty && _searchQuery.isEmpty) return;
    await refresh();
  }

  void filterServices(String query) {
    if (kDebugMode) {
      print(">>> 3. ServiceController.filterServices received query: '$query'");
    }
    _searchQuery = query;
    
    if (query.trim().isEmpty) {
      if (kDebugMode) {
        print(">>> 4. Query is empty. Restoring full list.");
      }
      _activeSearchQuery = ''; // Reset active search
      _services = List.from(_allServices);
      notifyListeners();
    } else {
      if (kDebugMode) {
        print(">>> 4. Query is valid. Calling refresh(search: '$query')...");
      }
      refresh(search: query);
    }
  }

  Future<void> refresh({String? search}) async {
    final queryKey = search ?? '';
    _activeSearchQuery = queryKey; // Mark this as the latest requested query

    if (kDebugMode) {
      print(">>> 5. refresh() executing with search parameter: '$search'");
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print(">>> 6. Calling ServiceApi.fetchServices...");
      }
      final fetched = await ServiceApi.fetchServices(search: search);
      
      // RACE CONDITION CHECK: If the user typed something else while this was loading, discard this result!
      if (_activeSearchQuery != queryKey) {
        if (kDebugMode) {
          print(">>> Discarding stale search response for: '$queryKey'");
        }
        return;
      }

      if (kDebugMode) {
        print(">>> 7. Fetch successful! Received ${fetched.length} items.");
      }
      
      if (search == null || search.trim().isEmpty) {
        _allServices = fetched;
        _services = List.from(_allServices);
      } else {
        _services = fetched;
      }
    } catch (e) {
      // Ensure we only process error if it matches current search
      if (_activeSearchQuery != queryKey) return;

      if (kDebugMode) {
        print(">>> X. FETCH ERROR: $e");
      }
      _error = _stripExceptionPrefix(e);
    } finally {
      // Only toggle loading off if this is still the active request
      if (_activeSearchQuery == queryKey) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _activeSearchQuery = '';
    _searchQuery = '';
    _services = List.from(_allServices);
    notifyListeners();
  }

  String _stripExceptionPrefix(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  void updateSearchQuery(String query) {
    filterServices(query);
  }

  void clear() {
    _allServices.clear();
    _services.clear();
    _activeSearchQuery = '';
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