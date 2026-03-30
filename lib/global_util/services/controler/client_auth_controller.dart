import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/client_auth_api.dart';

class ClientAuthProvider extends ChangeNotifier {
  
 
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  /// ==============================
  /// REGISTER
  /// ==============================
  /// 


  Future<bool> register() async {
  _isLoading = true;
  _error = null;
  fieldErrors = {};
  notifyListeners();

  try {
    final response = await ClientAuthApi.register(
      email: emailController.text.trim().toLowerCase(),
      mobile: mobileController.text.trim(),
      password: passwordController.text.trim(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // Handle backend validation errors properly
    if (body is Map<String, dynamic>) {
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

      if (errors.isNotEmpty) {
        fieldErrors = errors;
      }
    } else {
      _error = "Registration failed. Please try again.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  } catch (e) {
    _error = "Something went wrong. Please try again.";
    _isLoading = false;
    notifyListeners();
    return false;
  }
}








  Map<String, String?> fieldErrors = {};

 

 
  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
