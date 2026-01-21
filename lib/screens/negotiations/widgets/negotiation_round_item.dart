import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';

class NegotiationRoundItem extends StatelessWidget {
  final NegotiationRound round;
  const NegotiationRoundItem({super.key, required this.round});

  @override
  Widget build(BuildContext context) {
    final isClient = round.senderType == "client";
    return Align(
      alignment: isClient ? Alignment.centerLeft : Alignment.centerRight,
      child: Card(
        color: isClient ? Colors.grey.shade200 : Colors.blue.shade100,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (round.message != null && round.message!.isNotEmpty)
                Text(round.message!, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'} • ${round.createdAt != null ? DateFormat('HH:mm, dd MMM').format(round.createdAt!.toLocal()) : 'N/A'}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
