import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/cost_of_servicebyemail_api.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';



class CostOfServiceByemailController extends ChangeNotifier {
  List<CostOfServiceModel> costs = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchCostOfServiceByEmail(String email) async {
    isLoading = true;
    notifyListeners();

    try {
      costs = await CostOfServiceByEmailApi.fetchCostOfServiceByEmail(email);
      error = null;
    } catch (e) {
      error = e.toString();
      costs = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
