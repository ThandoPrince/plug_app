import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/view_client_pending_sevices.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';

class ClientPendingOrdersController extends ChangeNotifier {
  final ClientPendingOrdersApi api;

  ClientPendingOrdersController({ClientPendingOrdersApi? api})
      : api = api ?? ClientPendingOrdersApi();

  bool _disposed = false;

  List<OrderServiceModel> _pendingOrders = [];
  List<OrderServiceModel> get pendingOrders => _pendingOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasFetched = false;

  // Prevents a silent refresh from racing a foreground fetch (or another
  // silent refresh) and clobbering state out of order.
  bool _isSilentRefreshing = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // ───────────────────────────── CORE FETCH ─────────────────────────────

  Future<void> fetchPendingOrders({bool forceRefresh = false}) async {
    if (_disposed) return;

    // Prevent duplicate calls
    if (_isLoading) return;

    // Cache guard
    if (_hasFetched && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final orders = await api.fetchPendingOrdersByClientEmail();

      if (_disposed) return;

      _pendingOrders = orders;
      _hasFetched = true;
    } catch (e) {
      if (_disposed) return;

      if (kDebugMode) {
        print("ClientPendingOrdersController error: $e");
      }

      _errorMessage = _getSafeErrorMessage(e);
    } finally {
      if (_disposed) return;

      _isLoading = false;
      _safeNotify();
    }
  }

  // ───────────────────────────── SILENT REFRESH ─────────────────────────────

  /// Re-fetches in the background without touching isLoading, so the list
  /// already on screen doesn't flash a skeleton/spinner. Use this for
  /// socket-triggered refreshes (a round arrived, a negotiation was
  /// accepted) where the user is looking at a perfectly fine list and a
  /// full loading state would just be visual noise.
  ///
  /// Errors are swallowed on purpose — a background refresh failing
  /// shouldn't blank out or error-state a list that's currently showing
  /// valid (if slightly stale) data. The existing errorMessage/isLoading
  /// machinery is left untouched for the next real foreground fetch.
  Future<void> refreshSilently() async {
    if (_disposed) return;

    // Don't stack silent refreshes, and don't step on a real foreground
    // fetch that's already in flight — let that one finish and win.
    if (_isSilentRefreshing || _isLoading) return;

    _isSilentRefreshing = true;

    try {
      final orders = await api.fetchPendingOrdersByClientEmail();

      if (_disposed) return;

      _pendingOrders = orders;
      _hasFetched = true;
      _safeNotify();
    } catch (e) {
      if (kDebugMode) {
        print("ClientPendingOrdersController silent refresh error: $e");
      }
      // Intentionally not setting _errorMessage here.
    } finally {
      _isSilentRefreshing = false;
    }
  }

  // ───────────────────────────── SAFE ERROR ─────────────────────────────

  String _getSafeErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains("Server timeout")) {
      return "Server timeout. Please try again.";
    }

    if (message.contains("Server unreachable")) {
      return "Server unreachable. Check your internet connection.";
    }

    if (message.contains("Unable to process")) {
      return "Unable to process the server response. Please try again.";
    }

    return "Unable to load pending orders. Please try again.";
  }

  // ───────────────────────────── REFRESH ─────────────────────────────

  Future<void> refreshPendingOrders() async {
    await fetchPendingOrders(forceRefresh: true);
  }

  // ───────────────────────────── CLEAR ─────────────────────────────

  void clearOrders() {
    _pendingOrders = [];
    _hasFetched = false;
    _errorMessage = null;
    _safeNotify();
  }
}