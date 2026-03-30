import 'package:flutter/material.dart';

import 'package:flutter_application_1/const/services/cost_of_servicebyemail_api.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';

class CostOfServiceController extends ChangeNotifier {
  List<CostOfServiceModel> _costs = [];
  bool _isLoading = false;
  String? _error;

  List<CostOfServiceModel> get costs => _costs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCostsByEmailsAndService(
    List<String> emails,
    int serviceId,
  ) async {
    _isLoading = true;
    _error = null;
    _costs = [];
    notifyListeners();

    try {
      _costs = await CostOfServiceApi.fetchCostsByEmailsAndService(
        emails,
        serviceId,
      );

      if (_costs.isEmpty) {
        _error = 'No costs found for the selected providers and service.';
      }
    } catch (e) {
      _error = e.toString();
      _costs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCostByEmailAndService(
    String email,
    int serviceId,
  ) async {
    _isLoading = true;
    _error = null;
    _costs = [];
    notifyListeners();

    try {
      final cost = await CostOfServiceApi.fetchCostByEmailAndService(
        email,
        serviceId,
      );

      if (cost != null) {
        _costs = [cost];
      } else {
        _error = 'No cost found for this provider and service.';
      }
    } catch (e) {
      _error = e.toString();
      _costs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _costs = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}