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
      final result = await NegotiatiationRoundStartApi.startClientRound(
        negotiationId: negotiationId,
        offeredPrice: offeredPrice,
        message: message,
      );

      _isLoading = false;
      _errorMessage = result.success
          ? null
          : (result.error ?? "Failed to send negotiation round.");
      notifyListeners();
      return result.success;
    } catch (_) {
      // The API class catches its own errors, so this is a last-resort guard.
      _isLoading = false;
      _errorMessage = "Failed to send negotiation round.";
      notifyListeners();
      return false;
    }
  }
}