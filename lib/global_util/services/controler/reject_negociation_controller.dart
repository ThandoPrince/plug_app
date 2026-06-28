import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/reject_negociation_api.dart';


class RejectNegotiationController extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;
  String? _action;

  bool get isLoading => _isLoading;
  String? get message => _message;
  String? get action => _action;

  Future<bool> rejectNegotiation({
    required int negotiationId,
  }) async {
    _isLoading = true;
    _message = null;
    _action = null;

    notifyListeners();

    try {
      final response =
          await RejectNegotiationApi.rejectNegotiation(
        negotiationId: negotiationId,
      );

      _message = response["message"];
      _action = response["action"];

      return response["success"] == true;
    } catch (e) {
      _message = "Unable to process request.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _message = null;
    _action = null;
    notifyListeners();
  }
}