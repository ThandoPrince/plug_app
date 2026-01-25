import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'card_decoration.dart';

class SessionDetailsCard extends StatelessWidget {
  final SessionModel session;

  const SessionDetailsCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final shipment = session.shipment;
    final service = shipment?.serviceOrdered?.serviceRequired?.serviceName ?? '-';
    

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Session Details", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const Divider(height: 24),
          _detailItem(Icons.build_circle_outlined, "Job", service),
          _detailItem(Icons.calendar_month, "Date", session.dateCreated.toString() ?? '-'),
          _detailItem(Icons.location_on_rounded, "Destination", shipment?.serviceOrdered?.deliveryAddress?.formattedAddress),
          
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
