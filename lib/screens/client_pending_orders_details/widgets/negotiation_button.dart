import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/order_updates_badge_controller.dart';
import 'package:flutter_application_1/screens/negotiations/views/negotiations_by_orderID.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_accepted_screen.dart';
import 'package:provider/provider.dart';

class NegotiationButton extends StatelessWidget {
  final int orderId;

  const NegotiationButton({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount =
    context.watch<NegotiationBadgeStore>().countForOrder(orderId);

    return Material(
      color: Colors.blueAccent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final negotiationCtrl = Provider.of<NegotationByOrderIDController>(
            context,
            listen: false,
          );

          await negotiationCtrl.fetchAllNegotiations(orderId);

          if (!context.mounted) return;
          context.read<OrderUpdatesBadgeController>().clear(orderId);

          final hasAccepted = negotiationCtrl.negotiations?.any(
                (n) => (n.status ?? '').toLowerCase() == 'accepted',
              ) ??
              false;

          if (hasAccepted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NegotiationAcceptedScreen(orderId: orderId),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: negotiationCtrl,
                child: NegotiationsByOrderidScreen(orderId: orderId),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.handshake_outlined,
                color: Colors.blueAccent,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Text(
                "VIEW NEGOTIATION",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.blueAccent.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}