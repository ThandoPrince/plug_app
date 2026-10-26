// Client app. Drop into the check-in card, e.g. above the Amount Due row.
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/client_payment_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';
import 'package:flutter_application_1/screens/payment/views/payment_checkout_screen.dart';
import 'package:provider/provider.dart';



class PaymentStatusBanner extends StatelessWidget {
  const PaymentStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ClientPaymentController>();
    final p = ctrl.payment;

    if (p == null) return const SizedBox.shrink();

    // Paid
    if (p.isPaid) {
      return _box(
        color: Colors.green,
        icon: Icons.check_circle_outline,
        text: p.isCard ? 'Payment received. Your session is starting.' : 'Payment confirmed.',
      );
    }

    // Failed
    if (p.status == PaymentStatus.failed) {
      return _box(
        color: Colors.red,
        icon: Icons.error_outline,
        text: _failureText(p.failureReason),
        action: p.isCard
            ? _ActionButton(
                label: ctrl.isSelecting ? 'Please wait...' : 'Try again',
                onPressed: ctrl.isSelecting ? null : ctrl.retryCard,
              )
            : null,
      );
    }

    // Cash
    if (!p.isCard) {
      return _box(
        color: Colors.blueGrey,
        icon: Icons.money,
        text: 'Pay your provider in cash, now or when the session ends.',
      );
    }

    // Card, provider has scanned
    // if (p.readyToPay) {
    //   return _box(
    //     color: Kolors.kPrimary,
    //     icon: Icons.credit_card,
    //     text: 'Your provider has checked in. Pay ${p.amountLabel} to start the session.',
    //     action: _ActionButton(
    //       label: ctrl.isInitiating ? 'Opening...' : 'Pay now',
    //       onPressed: ctrl.isInitiating
    //           ? null
    //           : () => launchPaystackCheckout(context),
    //     ),
    //   );
    // }

    // Card, waiting for the scan
    return _box(
      color: Kolors.kPrimary,
      icon: Icons.hourglass_empty,
      text: 'Show this QR code to your provider. You will pay by card once they scan it.',
    );
  }

  String _failureText(String reason) {
    switch (reason) {
      case 'timed_out':
        return 'The payment timed out. Please try again.';
      case 'amount_mismatch':
        return 'The amount did not match the booking. Please contact support.';
      default:
        return 'The payment did not go through. Please try again.';
    }
  }

  Widget _box({
    required Color color,
    required IconData icon,
    required String text,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            action,
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Kolors.kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}