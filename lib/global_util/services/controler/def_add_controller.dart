import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/address_client_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';

class DefAddController extends ChangeNotifier {
  static const int _pageSize = 15;

  final List<AddressClientModel> _addresses = [];
  int _page = 0;
  int _generation = 0; // invalidates in-flight requests on refetch/clear
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String? _loadMoreError;

  List<AddressClientModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasLoadMoreError => _loadMoreError != null;
  String? get error => _error;

  /// First load (and refresh): reloads from page 1.
  Future<void> fetchAddresses() async {
    final gen = ++_generation;
    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await AddressClientsApi.getAddressesPage(
        page: 1,
        pageSize: _pageSize,
      );
      if (gen != _generation) return;

      _addresses
        ..clear()
        ..addAll(page.items);
      _page = 1;
      _hasMore = page.hasNext;
    } catch (e) {
      if (gen != _generation) return;
      _error = e.toString().replaceFirst('Exception: ', '');
      _addresses.clear();
      _page = 0;
      _hasMore = false;
    }

    if (gen != _generation) return;
    _isLoading = false;
    notifyListeners();
  }

  /// Call near the bottom of the list. `retry: true` bypasses the error
  /// guard so only a retry button re-fires a failed load.
  Future<void> loadMore({bool retry = false}) async {
    if (_isLoading || _isLoadingMore || !_hasMore || _page == 0) return;
    if (_loadMoreError != null && !retry) return;

    final gen = _generation;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await AddressClientsApi.getAddressesPage(
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (gen != _generation) return;

      final known = {for (final a in _addresses) a.id};
      _addresses.addAll(page.items.where((a) => !known.contains(a.id)));
      _page += 1;
      _hasMore = page.hasNext;
    } catch (e) {
      if (gen != _generation) return;
      _loadMoreError = e.toString().replaceFirst('Exception: ', '');
    }

    if (gen != _generation) return;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Clear controller state
  void clearAddresses() {
    _generation++;
    _addresses.clear();
    _page = 0;
    _hasMore = true;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _loadMoreError = null;
    notifyListeners();
  }
}