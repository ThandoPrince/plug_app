import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'card_decoration.dart';

class EtaCard extends StatelessWidget {
  final ShipmentRouteController routeController;
  final Shipment shipment;

  ShipmentStatusUI getShipmentStatusUI(String status) {
  switch (status) {
    case 'Pending':
      return const ShipmentStatusUI(
        label: 'Not In Transit',
        color: Colors.orange,
        icon: Icons.hourglass_bottom,
      );

    case 'in_transit':
      return const ShipmentStatusUI(
        label: 'In Transit',
        color: Colors.blue,
        icon: Icons.local_shipping,
      );

    case 'arrived': // ✅ ARRIVED
      return const ShipmentStatusUI(
        label: 'Arrived',
        color: Colors.green,
        icon: Icons.location_on,
      );

    case 'delivered':
      return const ShipmentStatusUI(
        label: 'Delivered',
        color: Colors.green,
        icon: Icons.check_circle,
      );

    default:
      return const ShipmentStatusUI(
        label: 'Unknown',
        color: Colors.grey,
        icon: Icons.help_outline,
      );
  }
}


  const EtaCard({super.key, required this.routeController, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final shipment = this.shipment;
    final route = routeController.activeRoute;
    final statusUI = getShipmentStatusUI(shipment.shipmentStatus);

    if (routeController.isLoading) {
      return Container(
        height: 100,
        decoration: cardDecoration(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final distanceKm = ((route?.distanceMeters ?? 0) / 1000).toStringAsFixed(1);
    final minutes = ((route?.durationSeconds ?? 0) / 60).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(Icons.directions_car, '$distanceKm km', 'Distance'),
          VerticalDivider(color: Colors.grey.shade200, thickness: 1),
          _buildMetric(Icons.access_time_rounded, '$minutes min', 'Arrival Time'),
          VerticalDivider(color: Colors.grey.shade200, thickness: 1),
         _buildMetric(
  statusUI.icon,
  statusUI.label,
  'Status',
  color: statusUI.color,
),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Kolors.kPrimary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(
          label,
          style: TextStyle(
              fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
class ShipmentStatusUI {
  final String label;
  final Color color;
  final IconData icon;

  const ShipmentStatusUI({
    required this.label,
    required this.color,
    required this.icon,
  });
}