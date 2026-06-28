import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/client_profile_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';

class ClientProfileController with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  ClientDetailModel? _clientProfile;
  List<ClientDetailModel>? _clientProfiles;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientDetailModel? get clientProfile => _clientProfile;
  List<ClientDetailModel>? get clientProfiles => _clientProfiles;

  /// Fetch single client by email
  Future<void> fetchClientByEmail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clientProfile = await ClientProfileApi.fetchClientProfile();
    } catch (e) {
      _errorMessage = e.toString();
      _clientProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all clients
  Future<void> fetchAllClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clientProfiles = await ClientProfileApi.fetchAllClients();
    } catch (e) {
      _errorMessage = e.toString();
      _clientProfiles = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
