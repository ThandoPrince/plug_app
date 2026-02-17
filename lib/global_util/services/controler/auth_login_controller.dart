import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class LoginController extends ChangeNotifier {
  // ---------------- Singleton ----------------
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  static LoginController get instance => _instance;
  LoginController._internal() {
    emailController.addListener(_clearEmailError);
    passwordController.addListener(_clearPasswordError);
  }

  // ---------------- Controllers ----------------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ---------------- State ----------------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _generalError;
  String? get generalError => _generalError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  final AuthLoginApi _apiHelper = AuthLoginApi();

  // ---------------- Public API ----------------
  Future<bool> login() async {
    _startLoading();
    _clearAllErrors();

    if (!_validateInputs()) {
      _stopLoading();
      return false;
    }

    try {
      final response = await _apiHelper.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final statusCode = response['statusCode'];
      final data = response['data'];

      if (response['statusCode'] == 200) {
  _userData = response['data'];

  final email = _userData?['email'];
  if (email != null) {
    await AuthSessionController.instance.setSession(email);
  }

  _isLoading = false;
  notifyListeners();
  return true;
}

      _handleBackendErrors(statusCode, data);
    } catch (_) {
      _generalError = "Unable to connect to the server.";
    }

    _stopLoading();
    return false;
  }

  // ---------------- Validation ----------------
  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _emailError = "Email is required.";
    }

    if (password.isEmpty) {
      _passwordError = "Password is required.";
    }

    if (_emailError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    final emailRegex =
        RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(email)) {
      _emailError = "Invalid email format.";
      notifyListeners();
      return false;
    }

    return true;
  }

  // ---------------- Backend Error Mapping ----------------
  void _handleBackendErrors(int statusCode, dynamic data) {
    if (statusCode == 400 && data is Map<String, dynamic>) {
      if (data.containsKey('email')) {
        _emailError = data['email']?.join("\n");
      } else if (data.containsKey('password')) {
        _passwordError = data['password']?.join("\n");
      } else if (data.containsKey('non_field_errors')) {
        _generalError =
            data['non_field_errors']?.join("\n") ??
            "Invalid credentials.";
      } else {
        _generalError =
            data['error'] ?? "Login failed.";
      }
    } else {
      _generalError =
          "Unexpected server error. Please try again.";
    }

    notifyListeners();
  }

  // ---------------- State Helpers ----------------
  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _clearAllErrors() {
    _generalError = null;
    _emailError = null;
    _passwordError = null;
  }

  void _clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      notifyListeners();
    }
  }

  void _clearPasswordError() {
    if (_passwordError != null) {
      _passwordError = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
