import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/households_api_helper.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';


class HouseholdController extends ChangeNotifier {
  List<AddressClientModel> _members = [];
  bool _isLoading = false;
  String? _error;

  List<AddressClientModel> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // =========================
  // FETCH
  // =========================
  Future<void> fetchHouseholdMembers(int clientAddressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await HouseholdApiHelper.getHouseholdMembers(clientAddressId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // RESET
  // =========================
  void clear() {
    _members = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}