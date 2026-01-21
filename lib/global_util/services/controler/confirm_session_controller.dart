import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/sessions/confirm_checkin_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_token_model.dart';


class ClientCheckinController extends ChangeNotifier {
  final ClientCheckinApi _api = ClientCheckinApi();

  bool isLoading = false;
  SessionTokenModel? token;
  String? error;
  Timer? _timer;
  Duration remaining = Duration.zero;

  
  Future<void> loadCheckinToken(int shipmentId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      
      token = await _api.fetchCheckinToken(shipmentId);
      _startCountdown();

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  void _startCountdown() {
  _timer?.cancel();

  if (token?.tokenExpiry == null) return;

  void tick() {
    final now = DateTime.now();
    remaining = token!.tokenExpiry!.difference(now);

    if (remaining.isNegative) {
      remaining = Duration.zero;
      _timer?.cancel();
    }

    notifyListeners();
  }

  tick(); // immediate update
  _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
}
@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}

String get formattedRemaining {
  if (isExpired) return "Expired";

  final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

  return "$minutes:$seconds";
}

  bool get isExpired => remaining <= Duration.zero;

  String get qrData => token?.checkinToken ?? "";
}