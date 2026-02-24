import 'dart:io';
import 'package:flutter/material.dart';

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

 
  Future<bool> submitVerification(int clientAddressId) async {
    if (_proofOfResidence == null || _idDocument == null) {
      error = "Both proof of residence and ID document are required.";
      notifyListeners();
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
      error = e.toString();
      notifyListeners();
      return false; 
    }
  }
}