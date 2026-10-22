import 'package:flutter/foundation.dart';

import 'package:flutter_application_1/const/services/registration/auth_login_api.dart'
    show ApiException;
import 'package:flutter_application_1/const/services/registration/change_password_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class ChangePasswordController extends ChangeNotifier {
  static const int minLength = 8; // keep in sync with the server validator

  bool _isLoading = false;
  String? _error;
  Map<String, String?> fieldErrors = {};

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_isLoading) return false;

    _error = null;
    fieldErrors = {};

    // ---- client-side checks (the server is still the source of truth) ----
    if (currentPassword.isEmpty) {
      fieldErrors['current_password'] = 'Enter your current password.';
    }
    if (newPassword.length < minLength) {
      fieldErrors['new_password'] =
          'Use at least $minLength characters.';
    } else if (newPassword == currentPassword) {
      fieldErrors['new_password'] =
          'New password must be different from the current one.';
    }
    if (confirmPassword != newPassword) {
      fieldErrors['confirm_password'] = 'Passwords do not match.';
    }

    if (fieldErrors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      final result = await ChangePasswordApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Old tokens are already invalid server-side. Swap in the new pair
      // right away so this device stays logged in.
      await AuthSessionController.instance.setSession(
        clientId: AuthSessionController.instance.clientId!,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      if (kDebugMode) print('Password changed, session refreshed.');
      return true;
    } on ApiException catch (e) {
      _applyApiError(e);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Maps DRF error shapes onto field errors and a general error.
  ///   {"new_password": ["too common"]}   -> field error
  ///   {"non_field_errors": ["..."]}      -> general error
  ///   {"detail": "..."} / {"error": ".."} -> general error
  void _applyApiError(ApiException e) {
    final data = e.data;

    if (data is Map) {
      const fields = ['current_password', 'new_password', 'confirm_password'];

      for (final f in fields) {
        final v = data[f];
        if (v != null) fieldErrors[f] = _first(v);
      }

      // Some serializers name it old_password.
      if (data['old_password'] != null) {
        fieldErrors['current_password'] = _first(data['old_password']);
      }

      final general = data['non_field_errors'] ?? data['detail'] ?? data['error'];
      if (general != null) _error = _first(general);
    }

    if (fieldErrors.isEmpty && _error == null) {
      _error = switch (e.statusCode) {
        401 => 'Your session has expired. Please log in again.',
        429 => 'Too many attempts. Please try again later.',
        _ => 'Could not change password. Please try again.',
      };
    }
  }

  String _first(dynamic v) {
    if (v is List && v.isNotEmpty) return v.first.toString();
    return v.toString();
  }

  void clearError() {
    _error = null;
    fieldErrors = {};
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}