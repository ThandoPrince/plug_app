import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/update_order_service_api.dart';

class UpdateOrderServiceController extends ChangeNotifier {
  final UpdateOrderServiceApi api;

  UpdateOrderServiceController({
    UpdateOrderServiceApi? api,
  }) : api = api ?? UpdateOrderServiceApi();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<bool> updateOrder({
    required int orderId,
    String? title,
    String? notes,
    String? requestedDate,
    String? requestedTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      await api.updateOrder(
        orderId: orderId,
        title: title,
        notes: notes,
        requestedDate: requestedDate,
        requestedTime: requestedTime,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }
}