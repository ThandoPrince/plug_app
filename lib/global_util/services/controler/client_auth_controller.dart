import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/client_auth_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class ClientAuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
  Future<bool> register() async {
  _setLoading(true);
  _clearErrors();

  try {
    final result = await ClientAuthApi.register(
      email: emailController.text.trim().toLowerCase(),
      mobile: mobileController.text.trim(),
      password: passwordController.text.trim(),
    );

    await AuthSessionController.instance.setSession(
      clientId: result.data.id,
      email: result.data.email,
      accessToken: result.data.accessToken,
      refreshToken: result.data.refreshToken,
    );

    _isSuccess = true;
    _setLoading(false);
    return true;
  } catch (e) {
    _error = e.toString();
    _setLoading(false);
    return false;
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
    final errors = <String, String?>{};

    body.forEach((key, value) {
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
          _error = message;
          break;
        default:
          _error = message;
      }
    });

    fieldErrors = errors;
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