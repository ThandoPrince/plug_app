import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';

import 'package:flutter_application_1/const/services/registration/address_verification_api.dart';

class AddressVerificationController extends ChangeNotifier {
  File? _proofOfResidence;
  File? _idDocument;

  bool isLoading = false;
  String? error;

  File? get proofOfResidence => _proofOfResidence;
  File? get idDocument => _idDocument;

  void setProofOfResidence(File file) {
    _proofOfResidence = file;
    notifyListeners();
  }

  void setIdDocument(File file) {
    _idDocument = file;
    notifyListeners();
  }

 
  Future<bool> submitVerification (
  BuildContext context,
  int clientAddressId,
) async {
  if (_proofOfResidence == null || _idDocument == null) {
    FlushbarService.warning(
      context,
      "Both documents are required",
    );
    return false;
  }

  isLoading = true;
  error = null;
  notifyListeners();

  try {
    final success = await AddressVerificationHelper.uploadVerification(
      clientAddressId: clientAddressId,
      proofOfResidence: _proofOfResidence!,
      idDocument: _idDocument!,
    );

    isLoading = false;
    notifyListeners();

    

    return success;
  } catch (e) {
    isLoading = false;

    String message = "Something went wrong";

    // -------------------------------------------------
    // Extract API exception
    // -------------------------------------------------
    if (e.toString().contains("ApiException")) {
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