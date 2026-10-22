import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/registration/delete_account_api.dart';

class DeleteAccountController extends ChangeNotifier {
  static const String requiredConfirmationWord = "DELETE";

  bool _isLoading = false;
  String? _error;
  Map<String, String> _fieldErrors = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get fieldErrors => _fieldErrors;

  Future<bool> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    _isLoading = true;
    _error = null;
    _fieldErrors = {};
    notifyListeners();

    try {
      await DeleteAccountApi.deleteAccount(
        password: password,
        confirmation: confirmation,
      );
      return true;
    } on DeleteAccountFieldException catch (e) {
      _fieldErrors = e.fieldErrors;
      return false;
    } catch (e) {
      _error = _stripExceptionPrefix(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _fieldErrors = {};
    notifyListeners();
  }

  String _stripExceptionPrefix(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }
}