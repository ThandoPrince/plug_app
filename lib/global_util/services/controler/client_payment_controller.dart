// Client app. Provide it above the check-in screen:
//   ChangeNotifierProvider(create: (_) => ClientPaymentController(), child: ...)
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/payment_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';



class ClientPaymentController extends ChangeNotifier {
  Payment? _payment;
  Payment? get payment => _payment;

  bool isSelecting = false;
  bool isInitiating = false;
  String? error;

  /// True while the Paystack WebView is on screen. Set by the launcher.
  bool checkoutOpen = false;

  Timer? _timer;
  int? _shipmentId;
  int? _autoLaunchedFor;
  bool _refreshing = false;
  bool _disposed = false;

  int? get shipmentId => _shipmentId;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Card chosen, provider scanned, and we haven't auto-opened checkout for this payment yet.
  /// Auto-launch happens once per payment; after that the user uses the "Pay now" button.
  bool get canAutoLaunch =>
      _payment != null &&
      _payment!.readyToPay &&
      !checkoutOpen &&
      !isInitiating &&
      _autoLaunchedFor != _payment!.paymentId;

  void markAutoLaunched() => _autoLaunchedFor = _payment?.paymentId;

  bool get priceLocked => _payment?.priceLocked ?? false;

  // ---- actions ----

  Future<bool> selectMethod({
    required int shipmentId,
    required PaymentMethod method,
  }) async {
    _shipmentId = shipmentId;
    isSelecting = true;
    error = null;
    _notify();

    try {
      _payment = await PaymentApi.selectMethod(
        shipmentId: shipmentId,
        method: method,
      );
      return true;
    } catch (e) {
      error = _message(e);
      return false;
    } finally {
      isSelecting = false;
      _notify();
    }
  }

  /// Call once when the check-in screen opens. Adopts a payment that already exists (so
  /// reopening the screen never overwrites an earlier choice); otherwise saves the screen's
  /// default method so the provider's scan always finds a payment row. Then starts polling.
  Future<Payment?> bootstrap({
    required int shipmentId,
    required PaymentMethod defaultMethod,
  }) async {
    _shipmentId = shipmentId;
    error = null;

    try {
      final existing = await PaymentApi.forShipment(shipmentId);
      final usable = existing != null &&
          existing.status != PaymentStatus.failed &&
          existing.status != PaymentStatus.refunded;

      if (usable) {
        _payment = existing;
        _notify();
      } else {
        await selectMethod(shipmentId: shipmentId, method: defaultMethod);
      }
    } catch (e) {
      error = _message(e);
      _notify();
    }

    startWatching(shipmentId);
    return _payment;
  }

  /// Re-select card after a failed attempt. A failed row is ignored server-side, so this
  /// creates a fresh payment.
  Future<bool> retryCard() {
    final id = _shipmentId;
    if (id == null) return Future.value(false);
    return selectMethod(shipmentId: id, method: PaymentMethod.card);
  }

  /// Asks the backend to open the Paystack transaction. Returns the payment with `checkout`.
  Future<Payment?> initiateCheckout() async {
    final current = _payment;
    if (current == null) return null;

    isInitiating = true;
    error = null;
    _notify();

    try {
      _payment = await PaymentApi.initiateCard(current.paymentId);
      return _payment;
    } catch (e) {
      error = _message(e);
      return null;
    } finally {
      isInitiating = false;
      _notify();
    }
  }

//   Future<void> verifyNow() async {
//   final current = _payment;
//   if (current == null || !current.isCard || _disposed) return;
//   try {
//     _payment = await PaymentApi.verifyCard(current.paymentId);
//     _notify();
//   } catch (_) {}
// }

// Future<void> pollUntilSettled({
//   Duration every = const Duration(seconds: 3),
//   int maxTries = 20,
// }) async {
//   for (var i = 0; i < maxTries && !_disposed; i++) {
//     await verifyNow();
//     if (_payment?.status.isTerminal ?? false) return;
//     await Future.delayed(every);
//   }
// }

  // ---- polling (fallback until the socket event is wired) ----

  void startWatching(int shipmentId, {Duration interval = const Duration(seconds: 4)}) {
    if (_shipmentId == shipmentId && _timer != null) return;
    _shipmentId = shipmentId;
    _timer?.cancel();
    refresh();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  void stopWatching() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() async {
    final id = _shipmentId;
    if (id == null || _refreshing || _disposed) return;
    _refreshing = true;
    try {
      final latest = await PaymentApi.forShipment(id);
      if (latest != null) {
        _payment = latest;
        _notify();
        if (latest.isPaid) stopWatching();
      }
    } catch (_) {
      // Transient network errors are fine; the next tick retries.
    } finally {
      _refreshing = false;
    }
  }

  /// After the checkout WebView closes: poll quickly until the webhook lands (or we give up).
  Future<void> pollUntilSettled({
    Duration every = const Duration(seconds: 2),
    int maxTries = 30,
  }) async {
    for (var i = 0; i < maxTries && !_disposed; i++) {
      await refresh();
      if (_payment?.status.isTerminal ?? false) return;
      await Future.delayed(every);
    }
  }

  void clearError() {
    error = null;
    _notify();
  }

  String _message(Object e) =>
      e is PaymentApiException ? e.message : 'Something went wrong. Please try again.';

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}