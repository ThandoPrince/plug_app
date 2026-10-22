import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/sessions/confirm_checkin_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_token_model.dart';


class ClientCheckinController extends ChangeNotifier {
  final ClientCheckinApi _api = ClientCheckinApi();

  bool isLoading = false;
  bool isRefreshing = false;
  SessionTokenModel? token;
  String? error;
  Timer? _timer;
  Duration remaining = Duration.zero;

  int? _shipmentId;

  Future<void> loadCheckinToken(int shipmentId) async {
    _shipmentId = shipmentId;

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

  /// Re-fetches a fresh token for the same shipment once the current one
  /// has expired. Uses a separate isRefreshing flag rather than isLoading
  /// so the UI can show a small inline spinner on the refresh action
  /// instead of swapping back to the full-screen loading state.
  Future<void> refreshToken() async {
    if (_shipmentId == null || isRefreshing) return;

    try {
      isRefreshing = true;
      error = null;
      notifyListeners();

      token = await _api.fetchCheckinToken(_shipmentId!);
      _startCountdown();
    } catch (e) {
      error = e.toString();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  void _startCountdown() {
    _timer?.cancel();

    if (token?.tokenExpiry == null) return;

    void tick() {
      final now = DateTime.now();
      remaining = token!.tokenExpiry.difference(now);

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