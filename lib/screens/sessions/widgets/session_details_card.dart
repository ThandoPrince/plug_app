import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/screens/order_details_/views/order_details_screen.dart';
import 'card_decoration.dart';

class SessionDetailsCard extends StatelessWidget {
  final SessionModel session;

  const SessionDetailsCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final shipment = session.shipment;
    final service =
        shipment?.serviceOrdered?.serviceRequired?.serviceName ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Session Details",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'order_details') {
                    final orderId = shipment?.serviceOrdered?.orderId;

                    if (orderId == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(
                          orderId: orderId,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'order_details',
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text("Order Details"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 24),
          _detailItem(Icons.build_circle_outlined, "Job", service),
          _detailItem(
            Icons.tag,
            "Order ID",
            shipment?.serviceOrdered?.orderId?.toString() ?? 'N/A',
          ),
          _detailItem(
            Icons.calendar_month,
            "Date",
            session.formattedDate,
          ),
          _detailItem(
            Icons.location_on_rounded,
            "Destination",
            shipment?.serviceOrdered?.deliveryAddress?.formattedAddress,
          ),
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
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold)),
                Text(value ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}