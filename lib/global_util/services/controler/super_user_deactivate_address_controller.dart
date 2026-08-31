import 'package:flutter/material.dart';

import 'package:flutter_application_1/common/widgets/flushbar_service.dart';

import 'package:flutter_application_1/const/services/client_services/super_user_deactivate_address_api.dart';

class SuperUserDeactivateAddressController
    extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  // =========================
  // SUPER USER DEACTIVATE
  // =========================
  Future<bool> deactivateAddress(
    BuildContext context,
    int clientAddressId,
  ) async {
    if (isLoading) {
      return false;
    }

    isLoading = true;
    error = null;

    notifyListeners();

    try {
      final success =
          await SuperUserDeactivateAddressHelper
              .deactivateAddress(
        clientAddressId: clientAddressId,
      );

      isLoading = false;

      notifyListeners();

      if (success) {
        FlushbarService.success(
          context,
          "Household member deactivated successfully.",
        );
      }

      return success;
    } catch (e) {
      isLoading = false;

      String message =
          "Something went wrong.";

      if (e
          is SuperUserDeactivateApiException) {
        message = e.message;
      } else {
        message = e.toString();
      }

      error = message;

      notifyListeners();

      FlushbarService.error(
        context,
        message,
      );

      return false;
    }
  }

  // =========================
  // CLEAR ERROR
  // =========================
  void clearError() {
    error = null;
    notifyListeners();
  }
}