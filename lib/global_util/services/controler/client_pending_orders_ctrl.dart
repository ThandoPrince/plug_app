import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/const/services/booking_services/view_client_pending_sevices.dart';

class ClientPendingOrdersController with ChangeNotifier {
  final ClientPendingOrdersApi api;

  ClientPendingOrdersController({ClientPendingOrdersApi? api})
      : api = api ?? ClientPendingOrdersApi();

  List<OrderServiceModel> _pendingOrders = [];
  List<OrderServiceModel> get pendingOrders => _pendingOrders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPendingOrders(String clientEmail) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orders = await api.fetchPendingOrdersByClientEmail(clientEmail);
      _pendingOrders = orders;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearOrders() {
    _pendingOrders = [];
    _errorMessage = null;
    notifyListeners();
  }
}
