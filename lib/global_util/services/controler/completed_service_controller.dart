import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/client_completed_services_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';

class ClientRatingsController extends ChangeNotifier {
  static const int _pageSize = 15;

  final List<RatingModel> _ratings = [];
  int _page = 0;            // last page successfully loaded
  int _generation = 0;      // invalidates in-flight requests on refresh
  bool _isLoading = false;  // first load / pull-to-refresh
  bool _isLoadingMore = false;
  bool _hasFetched = false;
  bool _hasMore = true;
  String? _loadMoreError;

  List<RatingModel> get ratings => List.unmodifiable(_ratings);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasLoadMoreError => _loadMoreError != null;

  /// First load: no-op if already fetched, unless [force] is true.
  Future<void> fetchRatings({bool force = false}) async {
    if (_isLoading && !force) return;
    if (_hasFetched && !force) return;

    final gen = ++_generation;
    _isLoading = true;
    _isLoadingMore = false;
    _loadMoreError = null;
    notifyListeners();

    try {
      final page = await ClientCompletedServicesApi.fetchRatingsPage(
        page: 1,
        pageSize: _pageSize,
      );
      if (gen != _generation) return;

      _ratings
        ..clear()
        ..addAll(page.items);
      _page = 1;
      _hasMore = page.hasNext;
      _hasFetched = true;
    } catch (e) {
      if (gen != _generation) return;
      // Keep whatever is already on screen instead of wiping it.
      debugPrint("Error fetching ratings: $e");
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
      final page = await ClientCompletedServicesApi.fetchRatingsPage(
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (gen != _generation) return;

      _ratings.addAll(page.items);
      _page += 1;
      _hasMore = page.hasNext;
    } catch (e) {
      if (gen != _generation) return;
      debugPrint("Error loading more ratings: $e");
      _loadMoreError = e.toString().replaceAll("Exception: ", "");
    }

    if (gen != _generation) return;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchRatings(force: true);
}