import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/const/services/registration/auth_login_api.dart';

import 'package:flutter_application_1/global_util/services/models/client_models/login_reponse_model.dart';

class LoginController extends ChangeNotifier {
  static final LoginController _instance = LoginController._internal();
  factory LoginController() => _instance;
  static LoginController get instance => _instance;

  LoginController._internal() {
    emailController.addListener(_clearEmailError);
    passwordController.addListener(_clearPasswordError);
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _generalError;
  String? get generalError => _generalError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  // Set once the password step succeeds. The OTP screen reads
  // maskedIdentifier off this to show "code sent to u***@example.com".
  LoginChallengeResponse? _challenge;
  LoginChallengeResponse? get challenge => _challenge;

  final AuthLoginApi _apiHelper = AuthLoginApi();

  // =========================
  // STEP 1: identifier + password
  // =========================
  // CHANGED: no longer sets the session or fetches the push token here.
  // On success this only proves the password was correct and stores a
  // verification token (handled inside AuthLoginApi.login()). The caller
  // should navigate to the OTP screen next; LoginOtpController.verifyOtp()
  // is what actually establishes the session.
  Future<bool> login() async {
    _startLoading();
    _clearAllErrors();

    if (!_validateInputs()) {
      _stopLoading();
      return false;
    }

    try {
      final challenge = await _apiHelper.login(
        identifier: emailController.text.trim().toString(),
        password: passwordController.text.trim(),
      );

      _challenge = challenge;
      return true;
    } on ApiException catch (e) {
      _handleBackendErrors(e.statusCode, e.data);
      return false;
    } catch (e) {
      _generalError = e.toString();
      notifyListeners();
      return false;
    } finally {
      _stopLoading();
    }
  }

  bool _validateInputs() {
    final identifier = emailController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty) {
      _emailError = "Email or mobile number is required.";
    }

    if (password.isEmpty) {
      _passwordError = "Password is required.";
    }

    if (_emailError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    final mobileRegex = RegExp(r'^(?:\+27|27|0)[6-8][0-9]{8}$');

    final isEmail = identifier.contains('@');
    final isMobile = RegExp(r'^\+?\d+$').hasMatch(identifier);

    if (isEmail) {
      if (!emailRegex.hasMatch(identifier)) {
        _emailError = "Enter a valid email address.";
        notifyListeners();
        return false;
      }
    } else if (isMobile) {
      if (!mobileRegex.hasMatch(identifier)) {
        _emailError = "Enter a valid mobile number.";
        notifyListeners();
        return false;
      }
    } else {
      _emailError = "Enter a valid email address or mobile number.";
      notifyListeners();
      return false;
    }

    return true;
  }

  void _handleBackendErrors(int statusCode, dynamic data) {
    _clearAllErrors();

    if (data is! Map<String, dynamic>) {
      _generalError = "Login failed.";
      notifyListeners();
      return;
    }

    switch (statusCode) {
      case 400:
      case 401:
        if (data['error'] != null) {
          _generalError = data['error'].toString();
        }
        break;
      case 403:
        _generalError = data['error']?.toString() ?? "Access denied.";
        break;
      case 404:
        _generalError = data['error']?.toString() ?? "User not found.";
        break;
      case 408:
        _generalError = "Server timeout. Please try again.";
        break;
      case 503:
        _generalError = "Unable to connect to the server.";
        break;
    }

    final errors = data['errors'];

    if (errors is Map<String, dynamic>) {
      if (errors['email'] is List) {
        _emailError = (errors['email'] as List).join('\n');
      }
      if (errors['identifier'] is List) {
        _emailError = (errors['identifier'] as List).join('\n');
      }
      if (errors['password'] is List) {
        _passwordError = (errors['password'] as List).join('\n');
      }
      if (errors['non_field_errors'] is List) {
        _generalError = (errors['non_field_errors'] as List).join('\n');
      }

      final meta = errors['meta'];
      if (meta is Map<String, dynamic>) {
        final remaining = meta['remaining_attempts'];
        if (remaining != null) {
          _generalError =
              "${_generalError ?? 'Invalid credentials.'} ($remaining attempts remaining)";
        }
      }
    }

    _generalError ??= data['message']?.toString() ??
        data['error']?.toString() ??
        "Login failed.";

    notifyListeners();
  }

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

  void clear() {
    emailController.clear();
    passwordController.clear();
    _generalError = null;
    _emailError = null;
    _passwordError = null;
    _challenge = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearSensitiveFields() {
    passwordController.clear();
    _passwordError = null;
    _generalError = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
