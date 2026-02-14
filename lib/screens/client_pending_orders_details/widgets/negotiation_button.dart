import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
import 'package:flutter_application_1/screens/negotiations/views/negotiations_by_orderID.dart';
import 'package:provider/provider.dart';

class NegotiationButton extends StatelessWidget {
  final int orderId;

  const NegotiationButton({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueAccent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final negotiationCtrl =
              Provider.of<NegotationByOrderIDController>(
            context,
            listen: false,
          );

          negotiationCtrl.fetchAllNegotiations(orderId);

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
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
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
