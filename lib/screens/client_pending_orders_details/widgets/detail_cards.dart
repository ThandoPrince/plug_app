import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:intl/intl.dart';

class RequestDetailsCard extends StatelessWidget {
  final OrderServiceModel booking;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const RequestDetailsCard({super.key, required this.booking, required this.primaryTextColor, required this.secondaryTextColor});

  String _formatDate(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  Color _getProposalPriceColor(String? status) {
    switch (status?.toLowerCase()) {
      case "completed": return Colors.green.shade700;
      case "in_progress": return Colors.amber.shade700;
      case "accepted": return Colors.blue.shade700;
      case "declined":
      case "rejected": return Colors.red.shade700;
      case "cancelled": return Colors.red.shade900;
      default: return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposalColor = _getProposalPriceColor(booking.status);

    return DetailCard(
      title: "Request Details",
      icon: Icons.receipt_long_rounded,
      primaryTextColor: primaryTextColor,
      children: [
         _IconDetailRow(
  icon: Icons.tag,
  label: "Order ID",
  value: booking.orderId.toString(),
  color: secondaryTextColor,
),
        _IconDetailRow(icon: Icons.work_outline, label: "Service Type", value: booking.serviceRequired?.serviceName ?? "N/A", color: secondaryTextColor),
        _IconDetailRow(icon: Icons.calendar_today_outlined, label: "Requested On", value: _formatDate(booking.requestedDateTime), color: secondaryTextColor),
        _IconDetailRow(icon: Icons.attach_money_rounded, label: "Proposal Price", value: "R ${booking.proposalPrice?.toStringAsFixed(2) ?? "TBD"}", color: proposalColor.withOpacity(0.9)),
      ],
    );
  }
}

class DeliveryAddressCard extends StatelessWidget {
  final OrderServiceModel booking;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const DeliveryAddressCard({super.key, required this.booking, required this.primaryTextColor, required this.secondaryTextColor});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: "Delivery Address",
      icon: Icons.location_on_outlined,
      primaryTextColor: primaryTextColor,
      children: [
        Text(booking.deliveryAddress?.formattedAddress ?? "N/A", style: TextStyle(fontSize: 15, color: secondaryTextColor)),
      ],
    );
  }
}

class NotesCard extends StatelessWidget {
  final OrderServiceModel booking;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const NotesCard({super.key, required this.booking, required this.primaryTextColor, required this.secondaryTextColor});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      title: "My Notes",
      icon: Icons.notes_rounded,
      primaryTextColor: primaryTextColor,
      children: [
        Text(booking.notes!, style: TextStyle(fontSize: 15, color: secondaryTextColor, fontStyle: FontStyle.italic)),
      ],
    );
  }
}



// -----------------
// Shared reusable widgets

class DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color primaryTextColor;

  const DetailCard({super.key, required this.title, required this.icon, required this.children, required this.primaryTextColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Kolors.kPrimary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryTextColor))),
              ],
            ),
            const Divider(height: 24, thickness: 1.5, color: Color.fromARGB(255, 235, 235, 235)),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _IconDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _IconDetailRow({super.key, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Kolors.kPrimary),
          const SizedBox(width: 12),
          SizedBox(width: 140, child: Text("$label:", style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 2)),
        ],
      ),
    );
  }
}
