import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'card_decoration.dart';

class EtaCard extends StatelessWidget {
  final GoogleShipmentRouteController routeController;
  final Shipment shipment;

  const EtaCard({
    super.key,
    required this.routeController,
    required this.shipment,
  });

  String _normalizeStatus(String status) => status.toLowerCase().trim();

  ShipmentStatusUI getShipmentStatusUI(String status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
      case 'rescheduled':
      case 'not_in_transit':
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

      case 'arrived':
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
          label: 'Processing',
          color: Colors.grey,
          icon: Icons.timelapse,
        );
    }
  }

  @override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: routeController,
    builder: (context, _) {
      final route = routeController.activeRoute;
      final normalizedStatus = _normalizeStatus(routeController.shipmentStatus);
      final statusUI = getShipmentStatusUI(routeController.shipmentStatus);

      // These statuses never have route data — there's nothing to wait
      // on, so skip the skeleton entirely and go straight to placeholders
      // instead of showing a loading state that will never resolve into
      // real numbers.
      const noRouteExpectedStatuses = {'pending', 'rescheduled', 'not_in_transit'};
      final noRouteExpected = noRouteExpectedStatuses.contains(normalizedStatus);

      final isInitialLoad = routeController.isLoading || routeController.isInitializing;

      if (isInitialLoad && route == null && !noRouteExpected) {
        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: cardDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSkeletonMetric(iconWidth: 24, valueWidth: 55, labelWidth: 45),
              Container(width: 1, height: 45, color: Colors.grey.shade200),
              _buildSkeletonMetric(iconWidth: 24, valueWidth: 45, labelWidth: 30),
              Container(width: 1, height: 45, color: Colors.grey.shade200),
              _buildSkeletonMetric(iconWidth: 24, valueWidth: 65, labelWidth: 40),
            ],
          ),
        );
      }

      // No route yet is a normal state (provider hasn't started moving /
      // no route created server-side yet, or the status simply never
      // produces route data) — NOT an error, so this card stays visible
      // rather than being hidden or replaced. Showing "0.0 km" / "0 min"
      // in that case would be actively misleading (it reads as "you have
      // arrived"), so show an honest placeholder instead until real
      // numbers exist.
      final hasRoute = route != null;

      final distanceLabel = hasRoute
          ? "${(route.distanceMeters / 1000).toStringAsFixed(1)} km"
          : "--";

      final etaLabel = hasRoute
          ? "${(route.durationSeconds / 60).round()} min"
          : "--";

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetric(Icons.directions_car, distanceLabel, 'Distance'),
            VerticalDivider(color: Colors.grey.shade200, thickness: 1),
            _buildMetric(Icons.access_time_rounded, etaLabel, 'ETA'),
            VerticalDivider(color: Colors.grey.shade200, thickness: 1),
            _buildMetric(statusUI.icon, statusUI.label, 'Status', color: statusUI.color),
          ],
        ),
      );
    },
  );
}


  Widget _buildSkeletonMetric({
  required double iconWidth,
  required double valueWidth,
  required double labelWidth,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _skeletonBox(
        width: iconWidth,
        height: 24,
        radius: 6,
      ),  

      const SizedBox(height: 8),

      _skeletonBox(
        width: valueWidth,
        height: 16,
        radius: 5,
      ),

      const SizedBox(height: 5),

      _skeletonBox(
        width: labelWidth,
        height: 10,
        radius: 4,
      ),
    ],
  );
}

Widget _skeletonBox({
  required double width,
  required double height,
  double radius = 5,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

  Widget _buildMetric(IconData icon, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Kolors.kPrimary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
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