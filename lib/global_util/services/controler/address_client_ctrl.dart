import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/client_services/address_client_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';

class AddressClientCtrl with ChangeNotifier {
  static const int _pageSize = 15;

  final List<AddressClientModel> _addresses = [];
  int _page = 0;
  int _generation = 0; // invalidates in-flight requests on refresh/clear
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasFetchedOnce = false;
  bool _hasMore = true;
  String? _errorMessage;
  String? _loadMoreError;

  List<AddressClientModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasLoadMoreError => _loadMoreError != null;
  String? get errorMessage => _errorMessage;

  /// Normal fetch (cached / anti-spam)
  Future<void> fetchAddresses() async {
    if (_hasFetchedOnce) return;
    await _loadFirstPage();
  }

  /// Forced refresh (pull-to-refresh / UI refresh): reloads from page 1.
  Future<void> refresh() => _loadFirstPage();

  Future<void> _loadFirstPage() async {
    final gen = ++_generation;
    _isLoading = true;
    _isLoadingMore = false;
    _errorMessage = null;
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
      _hasFetchedOnce = true;
    } catch (e) {
      if (gen != _generation) return;
      _errorMessage = _stripExceptionPrefix(e);
      _addresses.clear();
      _page = 0;
      _hasMore = false;
    }

    if (gen != _generation) return;
    _isLoading = false;
    notifyListeners();
  }

  /// Called near the bottom of the list. `retry: true` bypasses the error
  /// guard so only the retry button re-fires a failed load.
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
      _loadMoreError = _stripExceptionPrefix(e);
    }

    if (gen != _generation) return;
    _isLoadingMore = false;
    notifyListeners();
  }

  String _stripExceptionPrefix(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  /// Reset cache (use after updates like default address change)
  void resetCache() {
    _hasFetchedOnce = false;
  }

  void clearAddresses() {
    _generation++;
    _addresses.clear();
    _page = 0;
    _hasMore = true;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    _loadMoreError = null;
    _hasFetchedOnce = false;
    notifyListeners();
  }
}