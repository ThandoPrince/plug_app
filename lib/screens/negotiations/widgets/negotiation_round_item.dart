import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';

class NegotiationRoundItem extends StatelessWidget {
  final NegotiationRound round;
  const NegotiationRoundItem({super.key, required this.round});

  @override
  Widget build(BuildContext context) {
    final isClient = round.senderType == "client";
    final isFailed = round.isFailed;
    final isSending = round.isPending;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: isFailed
            ? Colors.red.shade50
            : isClient
                ? Colors.blue.shade400
                : Colors.grey.shade200,
        border: isFailed ? Border.all(color: Colors.red.shade300) : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isClient ? 16 : 4),
          bottomRight: Radius.circular(isClient ? 4 : 16),
        ),
      ),
      child: Opacity(
        opacity: isSending ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (round.message != null && round.message!.isNotEmpty)
              Text(
                round.message!,
                style: TextStyle(
                  fontSize: 14,
                  color: isClient ? Colors.white : Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isClient ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 6),
                if (isSending)
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isClient ? Colors.white70 : Colors.black45,
                    ),
                  )
                else if (isFailed)
                  Icon(Icons.error_outline, size: 13, color: Colors.red.shade600)
                else
                  Text(
                    round.createdAt != null
                        ? DateFormat('HH:mm').format(round.createdAt!.toLocal())
                        : '',
                    style: TextStyle(
                      fontSize: 11,
                      color: isClient ? Colors.white70 : Colors.black45,
                    ),
                  ),
                if (isFailed) ...[
                  const SizedBox(width: 6),
                  Text('Tap to retry',
                      style: TextStyle(fontSize: 11, color: Colors.red.shade600)),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}