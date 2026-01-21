// service_provider_controller.dart


import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/const/services/sp_api.dart';

class ServiceProviderController extends ChangeNotifier {
  List<ServiceProviderModel> _providers = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceProviderModel> get providers => _providers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllServiceProviders({int? serviceId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (serviceId != null) {
        _providers = await ServiceProviderApi.fetchAllServiceProviders(serviceId);
      
      } 
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

