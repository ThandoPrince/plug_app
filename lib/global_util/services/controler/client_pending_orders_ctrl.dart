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