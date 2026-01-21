import 'package:flutter/material.dart';

class NegotiatedPriceController extends ChangeNotifier {
  double? _proposedPrice;

  double? get proposedPrice => _proposedPrice;

  void updatePrice(String input) {
    if (input.isEmpty) {
      _proposedPrice = null;
    } else {
      _proposedPrice = double.tryParse(input.replaceAll(',', ''));
    }
    notifyListeners();
  }
}