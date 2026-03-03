import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/get_client_auth_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_auth.dart';


class GetClientAuthController extends ChangeNotifier {
  ClientAuthModel? _clientAuth;
  bool _isLoading = false;

  ClientAuthModel? get clientAuth => _clientAuth;
  bool get isLoading => _isLoading;

  Future<void> loadClientAuth(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await ClientAuthApi.fetchClientAuth(email);

    if (result != null) {
      _clientAuth = result;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _clientAuth = null;
    notifyListeners();
  }
}