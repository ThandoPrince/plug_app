import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/sessions/session_by_shipment_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';

class SessionByShipmentController extends ChangeNotifier {
  bool isLoading = false;
  SessionModel? session; // single session
  String? errorMessage;

  Timer? _pollingTimer;

  /// Fetch session once
  Future<void> fetchSession(String shipmentId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      session = await SessionApi.getSessionByShipment(shipmentId);
    } catch (e, stack) {
      errorMessage = e.toString();
      if (kDebugMode) {
        print("❌ ERROR in fetchSession: $e");
        print("📌 STACKTRACE: $stack");
      }
    } finally {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) print("fetchSession() finished");
    }
  }

  /// Start polling every [intervalSeconds] until session exists
  void startSessionPolling(String shipmentId, {int intervalSeconds = 5}) {
    _pollingTimer?.cancel(); // cancel existing timer if any
    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      try {
        final fetchedSession = await SessionApi.getSessionByShipment(shipmentId);
        if (fetchedSession != null) {
          session = fetchedSession;
          notifyListeners();

          // stop polling once session exists
          _pollingTimer?.cancel();
        }
      } catch (e) {
        errorMessage = e.toString();
        if (kDebugMode) print("❌ ERROR during polling: $e");
      }
    });
  }

  /// Stop polling manually
  void stopPolling() {
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
