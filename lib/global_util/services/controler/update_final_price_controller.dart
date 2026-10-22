import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/update_final_price_api.dart';


class PatchOrderFinalPriceController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  double? _updatedFinalPrice;
  bool? _isNegotiated;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  double? get updatedFinalPrice => _updatedFinalPrice;
  bool? get isNegotiated => _isNegotiated;

  Future<bool> patchFinalPrice({
    required int orderId,
    required double finalPrice,
    bool? isNegotiated,
  }) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

try {
  final result = await PatchOrderFinalPriceApi.patchFinalPrice(
    orderId: orderId,
    finalPrice: finalPrice,
    isNegotiated: isNegotiated,
  );

  _successMessage =
      result['message']?.toString() ?? 'Final price updated successfully.';

  final rawFinalPrice = result['final_price'];
  _updatedFinalPrice = rawFinalPrice != null
      ? double.tryParse(rawFinalPrice.toString())
      : finalPrice;

  _isNegotiated = result['is_negotiated'] is bool
      ? result['is_negotiated'] as bool
      : isNegotiated;

  return true;
} catch (e) {
  _error = _stripExceptionPrefix(e);
  return false;
} finally {
  _isLoading = false;
  notifyListeners();
}
  }

  void clearState() {
    _isLoading = false;
    _error = null;
    _successMessage = null;
    _updatedFinalPrice = null;
    _isNegotiated = null;
    notifyListeners();
  }
}

String _stripExceptionPrefix(Object e) {
  final raw = e.toString();
  const prefix = 'Exception: ';
  return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
}