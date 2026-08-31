import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/client_auth_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';




class ClientAuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  bool _isLoading = false;
  String? _error;
  Map<String, String?> fieldErrors = {};

  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  // ======================
  // REGISTER
  // ======================
  // ======================
  // REGISTER
  // ======================
  // client_auth_provider.dart
Future<bool> register() async {
  _setLoading(true);
  _clearErrors();

  try {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      fieldErrors['confirmPassword'] = "Passwords do not match";
      _setLoading(false);
      notifyListeners();
      return false;
    }

    final result = await ClientAuthApi.register(
      email: emailController.text.trim().toLowerCase(),
      mobile: mobileController.text.trim(),
      password: passwordController.text.trim(),
    );

    await AuthSessionController.instance.setOtpSession(
      email: result.data.email,
      clientId: result.data.id,
      requiresEmailVerification: result.data.requiresEmailVerification,
      otpRequestId: result.data.otpRequestId,
      verificationToken: result.data.verificationToken,
    );

    _isSuccess = true;
    _setLoading(false);
    notifyListeners();
    return true;

  } on ApiException catch (e) {
    if (e.fieldErrors != null) {
      fieldErrors = e.fieldErrors!.map(
        (key, value) => MapEntry(
          _mapFieldKey(key),
          value is List ? value.join('\n') : value.toString(),
        ),
      );
    }
    // Top-level message (duplicate email/mobile, OTP cooldown 429, 409, 500, etc.)
    _error = e.message ?? "Incorrect information was provided. Please try again.";
    _setLoading(false);
    notifyListeners();
    return false;

  } catch (e) {
    _error = e.toString().replaceFirst('Exception: ', '');
    _setLoading(false);
    notifyListeners();
    return false;
  }
}

String _mapFieldKey(String backendKey) {
  switch (backendKey) {
    case 'email_address':
      return 'email';
    case 'mobile_number':
      return 'mobile';
    default:
      return backendKey;
  }
}



  // ======================
  // Helpers
  // ======================
  Map<String, dynamic> _safeDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  void _handleErrors(Map<String, dynamic> body) {
    // 1. Start with a fresh map copy to clear old states, but preserve client-side if needed
    final errors = <String, String?>{};

    body.forEach((key, value) {
      // Convert list of messages or single string into a clean layout string
      final message = (value is List && value.isNotEmpty)
          ? value.join('\n')
          : value.toString();

      switch (key) {
        case 'email_address':
          errors['email'] = message;
          break;
        case 'mobile_number':
          errors['mobile'] = message;
          break;
        case 'password':
          errors['password'] = message;
          break;
        case 'non_field_errors':
        case 'detail':
          _error = message;
          break;
        default:
          // Catch-all for unexpected backend validation keys
          errors[key] = message;
          break;
      }
    });

    // 2. Assign the complete multi-field error map to the UI state holder
    fieldErrors = errors;
    notifyListeners(); // Force UI fields to redraw with their respective errors
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _error = null;
    fieldErrors = {};
    _isSuccess = false;
  }

  // ======================
  // Dispose
  // ======================
  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}