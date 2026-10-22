import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/households_api_helper.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/household_model.dart';

class HouseholdController extends ChangeNotifier {
  static const int _pageSize = 15;

  final List<HouseHoldModel> _members = [];
  int? _addressId;
  int _page = 0;
  int _generation = 0; // invalidates in-flight requests on refetch/clear
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String? _loadMoreError;

  List<HouseHoldModel> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasLoadMoreError => _loadMoreError != null;
  String? get error => _error;

  // =========================
  // FETCH (first load / refresh): reloads from page 1
  // =========================
  Future<void> fetchHouseholdMembers(int clientAddressId) async {
    final gen = ++_generation;

    // A different address means the old rows are wrong; clear them.
    if (_addressId != clientAddressId) {
      _members.clear();
      _page = 0;
      _hasMore = true;
    }
    _addressId = clientAddressId;

    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _loadMoreError = null;
    notifyListeners();

    try {
      final result = await HouseholdApiHelper.getHouseholdMembersPage(
        clientAddressId,
        page: 1,
        pageSize: _pageSize,
      );
      if (gen != _generation) return;

      _members
        ..clear()
        ..addAll(result.items);
      _page = 1;
      _hasMore = result.hasNext;
    } catch (e) {
      if (gen != _generation) return;
      _error = _stripExceptionPrefix(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // LOAD MORE: appends the next page
  // =========================
  Future<void> loadMore({bool retry = false}) async {
    final addressId = _addressId;
    if (addressId == null) return;
    if (_isLoading || _isLoadingMore || !_hasMore || _page == 0) return;
    if (_loadMoreError != null && !retry) return;

    final gen = _generation;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final result = await HouseholdApiHelper.getHouseholdMembersPage(
        addressId,
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (gen != _generation) return;

      final known = {for (final m in _members) m.id};
      _members.addAll(result.items.where((m) => !known.contains(m.id)));
      _page += 1;
      _hasMore = result.hasNext;
    } catch (e) {
      if (gen != _generation) return;
      _loadMoreError = _stripExceptionPrefix(e);
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Exception's default toString() is "Exception: <message>"; strip
  /// that prefix so the UI only ever shows the human-readable message.
  String _stripExceptionPrefix(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  // =========================
  // RESET
  // =========================
  void clear() {
    _generation++;
    _members.clear();
    _addressId = null;
    _page = 0;
    _hasMore = true;
    _isLoading = false;
    _isLoadingMore = false;
    _error = null;
    _loadMoreError = null;
    notifyListeners();
  }
}