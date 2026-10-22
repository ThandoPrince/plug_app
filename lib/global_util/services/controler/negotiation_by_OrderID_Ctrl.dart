import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/fetch_negotiation_by_OrderID_api.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';

class NegotationByOrderIDController with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<NegotiationModel>? _negotiation;
  List<NegotiationModel>? _negotiations;

  int? _lastFetchedOrderId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NegotiationModel>? get negotiation => _negotiation;
  List<NegotiationModel>? get negotiations => _negotiations;

  Future<void> fetchNegociationByEmail(int orderID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _negotiation = await NegotiationByOrderidApi.fetchNegotiationByOrderID(orderID);
    } catch (e) {
      _errorMessage = e.toString();
      _negotiation = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all negotiations for an order. If we already have data for
  /// this exact orderID, this is a no-op unless [force] is true — this is
  /// what stops the negotiations screen from refetching every time it's
  /// opened. Pull-to-refresh and post-removal reloads should pass
  /// force: true.
  Future<void> fetchAllNegotiations(int orderID, {bool force = false}) async {
    if (!force &&
        _lastFetchedOrderId == orderID &&
        _negotiations != null &&
        _errorMessage == null) {
      return;
    }

    // Only show the full skeleton on a true first load — don't blank the
    // list out from under the user on a forced refresh of data we already
    // have something for.
    _isLoading = _negotiations == null || _errorMessage != null;
    _errorMessage = null;
    notifyListeners();

    try {
      _negotiations = await NegotiationByOrderidApi.fetchNegotiationByOrderID(orderID);
      _lastFetchedOrderId = orderID;
    } catch (e) {
      _errorMessage = e.toString();
      _negotiations = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}