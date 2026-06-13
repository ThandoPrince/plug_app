import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/sp_by_email_api.dart';
import '../models/service_provider_model.dart';


class ServiceProviderByEmailController extends ChangeNotifier {
  ServiceProviderModel? provider;
  bool isLoading = false;
  String? error;



  Future<void> fetchProviderByEmail(int id) async {
    isLoading = true;
    notifyListeners();



    try {
      provider = await ServiceProviderByEmailApi.fetchProviderByEmail(id);
      error = null;
    } catch (e) {
      error = e.toString();
      provider = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
