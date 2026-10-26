// Provider app. Shown after a successful check-in scan when the session is `awaiting_payment`.
// Polls the payment until the client has paid, then hands off via [onPaid]. The navigation to
// SessionScreen lives in the caller so this screen doesn't need to know about session types.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/const/services/booking_services/payment_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';


class WaitingForPaymentScreen extends StatefulWidget {
  final int shipmentId;

  /// Called once, when the payment has succeeded. Typically refetches the session and
  /// pushes SessionScreen.
  final Future<void> Function(BuildContext context) onPaid;

  /// Poll interval. A socket event should make this redundant, but keep it as a fallback.
  final Duration pollEvery;

  const WaitingForPaymentScreen({
    super.key,
    required this.shipmentId,
    required this.onPaid,
    this.pollEvery = const Duration(seconds: 4),
  });

  @override
  State<WaitingForPaymentScreen> createState() => _WaitingForPaymentScreenState();
}

class _WaitingForPaymentScreenState extends State<WaitingForPaymentScreen> {
  Timer? _timer;
  Payment? _payment;
  bool _handled = false;
  bool _polling = false;
  bool _networkTrouble = false;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(widget.pollEvery, (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_polling || _handled || !mounted) return;
    _polling = true;
    try {
      final latest = await PaymentApi.forShipment(widget.shipmentId);
      if (!mounted) return;

      setState(() {
        _payment = latest ?? _payment;
        _networkTrouble = false;
      });

      if (latest != null && latest.isPaid) {
        _handled = true;
        _timer?.cancel();
        await widget.onPaid(context);
      }
    } catch (_) {
      if (mounted) setState(() => _networkTrouble = true);
    } finally {
      _polling = false;
    }
  }

  Future<bool> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this screen?'),
        content: const Text(
          'The session will not start until the client pays. You can come back to it '
          'from your schedule.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  String get _headline {
    final p = _payment;
    if (p == null) return 'Waiting for the client';
    if (p.status == PaymentStatus.failed) return 'Payment did not go through';
    return 'Waiting for client payment';
  }

  String get _detail {
    final p = _payment;
    if (p == null) {
      return 'The client has not chosen a payment type yet.';
    }
    if (p.status == PaymentStatus.failed) {
      return 'The client can try again from their app. This screen will update automatically.';
    }
    return 'The client has been asked to pay ${p.amountLabel} by card. '
        'The session starts automatically once it is confirmed.';
  }

  @override
  Widget build(BuildContext context) {
    final failed = _payment?.status == PaymentStatus.failed;
    final accent = failed ? Colors.redAccent : Kolors.kPrimary;

    return WillPopScope(
      onWillPop: _confirmLeave,
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text('Payment'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _confirmLeave() && mounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    failed ? Icons.error_outline : Icons.hourglass_top_rounded,
                    color: accent,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _headline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                if (_payment != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withOpacity(0.25)),
                    ),
                    child: Text(
                      _payment!.amountLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (!failed)
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      color: accent,
                      backgroundColor: Colors.white12,
                      minHeight: 3,
                    ),
                  ),
                if (_networkTrouble) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Having trouble reaching the server. Retrying...',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _poll,
                  child: const Text('Check status now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}