import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/client_auth_api.dart';


class ClientAuthProvider extends ChangeNotifier {
  /// Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  /// ==============================
  /// REGISTER
  /// ==============================

  Future<void> register() async {
  _setLoading(true);
  _error = null;
  _isSuccess = false;

  final email = emailController.text.trim();
  final mobile = mobileController.text.trim();
  final password = passwordController.text.trim();

  // Basic client-side validation
  if (email.isEmpty || mobile.isEmpty || password.isEmpty) {
    _setFieldErrors({
      'email': email.isEmpty ? 'Email is required' : null,
      'mobile': mobile.isEmpty ? 'Mobile is required' : null,
      'password': password.isEmpty ? 'Password is required' : null,
    });
    return;
  }

  if (!email.contains('@')) {
    _setFieldErrors({'email': 'Invalid email format'});
    return;
  }

  if (password.length < 6) {
    _setFieldErrors({'password': 'Password must be at least 6 characters'});
    return;
  }

  try {
    final response = await ClientAuthApi.register(
      email: email,
      mobile: mobile,
      password: password,
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      _isSuccess = true;
      notifyListeners();
    } else if (body is Map<String, dynamic>) {
      // Backend validation errors
      final fieldErrors = <String, String>{};
      body.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          fieldErrors[key] = value.join('\n'); // Join multiple errors
        } else if (value is String) {
          fieldErrors[key] = value;
        }
      });
      _setFieldErrors(fieldErrors);
    } else {
      _setError('Something went wrong. Please try again.');
    }
  } catch (e) {
    _setError('Something went wrong. Please try again.');
  }
}

/// State to hold field-specific errors
Map<String, String?> fieldErrors = {};

void _setFieldErrors(Map<String, String?> errors) {
  fieldErrors = errors;
  _isLoading = false;
  notifyListeners();
}




  /// ==============================
  /// HELPERS
  /// ==============================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Dispose controllers properly
  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
