import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';

import 'package:flutter_application_1/const/services/registration/address_verification_api.dart';

class AddressVerificationController extends ChangeNotifier {
  File? _proofOfResidence;
  File? _idDocument;
  File? _livenessVideo;

  String _idNumber = '';

  bool isLoading = false;
  String? error;

  File? get proofOfResidence => _proofOfResidence;
  File? get idDocument => _idDocument;
  File? get livenessVideo => _livenessVideo;
  String get idNumber => _idNumber;

  void setIdNumber(String value) {
    _idNumber = value.trim();
    notifyListeners();
  }

  void setProofOfResidence(File file) {
    _proofOfResidence = file;
    notifyListeners();
  }

  void setIdDocument(File file) {
    _idDocument = file;
    notifyListeners();
  }

  void setLivenessVideo(File file) {
    _livenessVideo = file;
    notifyListeners();
  }

  Future<bool> submitVerification(
    BuildContext context,
    int clientAddressId,
  ) async {
    if (_idNumber.isEmpty) {
      FlushbarService.warning(
        context,
        "Please enter your ID number",
      );
      return false;
    }

    if (_proofOfResidence == null ||
        _idDocument == null ||
        _livenessVideo == null) {
      FlushbarService.warning(
        context,
        "All documents — including the liveness video — are required",
      );
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success =
          await AddressVerificationHelper.uploadVerification(
        clientAddressId: clientAddressId,
        idNumber: _idNumber,
        proofOfResidence: _proofOfResidence!,
        idDocument: _idDocument!,
        livenessVideo: _livenessVideo!,
      );

      isLoading = false;
      notifyListeners();

      return success;
} catch (e) {
  isLoading = false;

  String message = "Something went wrong";

  if (e is ApiException) {
    message = e.message;
  } else {
    message = e.toString();
  }

  error = message;
  notifyListeners();

  FlushbarService.error(context, message);

  return false;
}
  }
}

String? _extractFirstError(Map<String, dynamic> errors) {
  for (final value in errors.values) {
    if (value is List && value.isNotEmpty) {
      return value[0].toString();
    }

    if (value is String) {
      return value;
    }
  }
  return null;
}