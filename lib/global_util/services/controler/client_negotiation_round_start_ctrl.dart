import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/negotiation_round_start_by_id_api.dart';


class ClientStartRoundController with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> sendRound({
    required int negotiationId,
    required double offeredPrice,
    String? message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await NegotiatiationRoundStartApi.startClientRound(
        negotiationId: negotiationId,
        offeredPrice: offeredPrice,
        message: message,
      );
      _isLoading = false;
      if (!success) {
        _errorMessage = "Failed to send negotiation round.";
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
