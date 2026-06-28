import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/logout_api.dart';
import 'package:flutter_application_1/global_util/services/api_exeption.dart';


class LogoutController with ChangeNotifier {
  final LogoutApi _api = LogoutApi();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> logout() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.logout();
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = "Unexpected error occurred";
    }

    _loading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}