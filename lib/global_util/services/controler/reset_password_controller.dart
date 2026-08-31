// reset_password_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/reset_password_api.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart' show ApiException;
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class ResetPasswordController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _otpSent = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get otpSent => _otpSent;


  Future<bool> requestOtp({
    String? email,
    String? mobileNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final challenge = await ResetPasswordApi.requestOtp(
        email: email,
        mobileNumber: mobileNumber,
      );

      await AuthSessionController.instance.updateVerificationToken(
        challenge.data.verificationToken,
        otpRequestId: challenge.data.otpRequestId,
      );

      _otpSent = true;
      return true;
    } on ApiException catch (e) {
      _handleBackendError(e.statusCode, e.data);
      return false;
    } catch (e) {
      _errorMessage = "Unexpected error occurred. Please try again.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // reset_password_controller.dart — add alongside requestOtp()
Future<bool> confirmReset({
  required String otp,
  required String newPassword,
}) async {
  final verificationToken = AuthSessionController.instance.verificationToken;

  if (verificationToken == null || verificationToken.isEmpty) {
    _errorMessage = "Your session expired. Please request a new code.";
    notifyListeners();
    return false;
  }

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await ResetPasswordApi.confirmReset(
      otp: otp,
      newPassword: newPassword,
      verificationToken: verificationToken,
    );

    if (response['success'] == true) {
      return true;
    }

    _errorMessage = response['message'] ?? 'Failed to reset password.';
    return false;
  } on ApiException catch (e) {
    _handleBackendError(e.statusCode, e.data);
    return false;
  } catch (e) {
    _errorMessage = "Unexpected error occurred. Please try again.";
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  void _handleBackendError(int statusCode, dynamic data) {
    if (data is! Map<String, dynamic>) {
      _errorMessage = "Failed to send verification code.";
      return;
    }

    switch (statusCode) {
      case 404:
        _errorMessage = "No account found with that email or mobile number.";
        return;
      case 403:
        // account_locked_until branch — backend returns {"error": [...]}
        break;
      case 409:
        _errorMessage = "Multiple accounts found. Contact support.";
        return;
      case 429:
        _errorMessage = data['message']?.toString() ?? "Please wait before retrying.";
        return;
    }

    final error = data['error'];
    if (error is List) {
      _errorMessage = error.join('\n');
    } else if (error != null) {
      _errorMessage = error.toString();
    } else {
      _errorMessage = data['message']?.toString() ?? "Failed to send verification code.";
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _otpSent = false;
    notifyListeners();
  }
}