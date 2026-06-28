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

    // 🔒 prevent duplicate calls
    if (_isLoading) return;

    // 🔥 cache guard
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
      _errorMessage = e.toString();
    } finally {
      if (_disposed) return;

      _isLoading = false;
      _safeNotify();
    }
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