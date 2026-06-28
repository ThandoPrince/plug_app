import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/update_profile_api.dart';
import 'package:flutter_application_1/global_util/services/api_exeption.dart';


class ClientProfileUpdateController extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get message => _message;
  String? get errorMessage => _errorMessage;

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    File? profilePicture,
  }) async {
    _isLoading = true;
    _message = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await UpdateProfileApi.updateProfile(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        profilePicture: profilePicture,
      );

      _message =
          response['message'] ?? 'Profile updated successfully';

      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage =
          'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}