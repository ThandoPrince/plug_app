import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/reset_password_api.dart';



class ResetPasswordController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> resetPassword({
    String? email,
    String? mobileNumber,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response =
          await ResetPasswordApi.resetPassword(
        email: email,
        mobileNumber: mobileNumber,
        newPassword: newPassword,
      );

      if (response['success'] == true) {
        _successMessage = response['message'];
        return true;
      }

      _errorMessage =
          response['message'] ?? 'Something went wrong.';
      return false;
    } catch (e) {
      _errorMessage =
          'Unexpected error occurred. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}