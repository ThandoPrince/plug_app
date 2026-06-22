import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/cancel_order_api.dart';



class CancelOrderController extends ChangeNotifier {
  final CancelOrderApiHelper _api =
      CancelOrderApiHelper();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> cancelOrder({
    required int orderId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.cancelOrder(
        orderId: orderId,
      );

      return result["success"] == true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}