import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_application_1/const/services/registration/auth_login_api.dart'
    show ApiException;
import 'package:flutter_application_1/const/services/registration/authenticated_reset_password_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class AuthenticatedResetPasswordController extends ChangeNotifier {
  static const int minLength = 8;
  static const int defaultCooldownSeconds = 60; // match server OTP cooldown

  bool _isSending = false;
  bool _isSubmitting = false;
  String? _error;
  Map<String, String?> fieldErrors = {};

  String? _otpRequestId;
  String _maskedEmail = '';

  int _resendSecondsLeft = 0;
  Timer? _timer;

  bool get isSending => _isSending;
  bool get isSubmitting => _isSubmitting;
  bool get isBusy => _isSending || _isSubmitting;
  String? get error => _error;
  String get maskedEmail => _maskedEmail;
  bool get codeSent => _otpRequestId != null;
  int get resendSecondsLeft => _resendSecondsLeft;
  bool get canResend => !isBusy && _resendSecondsLeft == 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------- step 1
  Future<bool> requestOtp() async {
    if (_isSending) return false;

    _isSending = true;
    _error = null;
    fieldErrors = {};
    notifyListeners();

    try {
      final challenge = await AuthenticatedResetPasswordApi.requestOtp();
      _otpRequestId = challenge.otpRequestId;
      _maskedEmail = challenge.maskedEmail;
      _startCooldown(defaultCooldownSeconds);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 429 && e.data is Map) {
        final retry = int.tryParse('${(e.data as Map)['retry_after']}');
        _startCooldown(retry ?? defaultCooldownSeconds);
      }
      _error = _messageFrom(e, fallback: 'Could not send verification code.');
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------- step 2
  Future<bool> confirmReset({
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_isSubmitting) return false;

    _error = null;
    fieldErrors = {};

    if (_otpRequestId == null) {
      _error = 'Request a verification code first.';
      notifyListeners();
      return false;
    }

    // client-side checks (server remains the source of truth)
    if (otp.trim().isEmpty) {
      fieldErrors['otp'] = 'Enter the verification code.';
    }
    final pwError = _passwordError(newPassword);
    if (pwError != null) fieldErrors['new_password'] = pwError;
    if (confirmPassword != newPassword) {
      fieldErrors['confirm_password'] = 'Passwords do not match.';
    }
    if (fieldErrors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await AuthenticatedResetPasswordApi.confirmReset(
        otp: otp.trim(),
        otpRequestId: _otpRequestId!,
        newPassword: newPassword,
      );

      // Old tokens are dead (session_version bumped) - persist the new pair now.
      await AuthSessionController.instance.setSession(
        clientId: AuthSessionController.instance.clientId!,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      if (kDebugMode) print('Password reset via OTP, session refreshed.');
      return true;
    } on ApiException catch (e) {
      _error = _messageFrom(e, fallback: 'Could not reset password.');
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------- helpers
  String? _passwordError(String v) {
    if (v.length < minLength) return 'Use at least $minLength characters.';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Include an uppercase letter.';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Include a lowercase letter.';
    if (!RegExp(r'\d').hasMatch(v)) return 'Include a digit.';
    return null;
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    _resendSecondsLeft = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSecondsLeft <= 1) {
        _resendSecondsLeft = 0;
        t.cancel();
      } else {
        _resendSecondsLeft--;
      }
      notifyListeners();
    });
  }

  /// Handles the shapes this backend (and DRF's throttle) can return:
  ///   {"error": "..."} | {"error": ["...", "..."]}
  ///   {"success": false, "message": "..."} | {"detail": "..."}
  String _messageFrom(ApiException e, {required String fallback}) {
    final data = e.data;
    if (data is Map) {
      final raw = data['error'] ?? data['message'] ?? data['detail'];
      if (raw is List && raw.isNotEmpty) return raw.join('\n');
      if (raw != null && raw.toString().isNotEmpty) return raw.toString();
    }
    return switch (e.statusCode) {
      401 => 'Your session has expired. Please log in again.',
      403 => 'Account is temporarily locked. Try again later.',
      429 => 'Too many attempts. Please try again later.',
      _ => fallback,
    };
  }

  void clearError() {
    if (_error == null && fieldErrors.isEmpty) return;
    _error = null;
    fieldErrors = {};
    notifyListeners();
  }
}