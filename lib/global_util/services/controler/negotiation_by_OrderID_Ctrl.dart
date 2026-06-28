import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/fetch_negotiation_by_OrderID_api.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';

class NegotationByOrderIDController with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<NegotiationModel>? _negotiation;
  List<NegotiationModel>? _negotiations;

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

  
  Future<void> fetchAllNegotiations(int orderID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _negotiations = await NegotiationByOrderidApi.fetchNegotiationByOrderID(orderID);
    } catch (e) {
      _errorMessage = e.toString();
      _negotiations = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
