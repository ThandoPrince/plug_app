import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/screens/sessions/widgets/ui_status_helper.dart';
import 'card_decoration.dart';

class SessionEtaCard extends StatefulWidget {
  final GoogleShipmentRouteController controller;
  final SessionModel session;

  const SessionEtaCard({
    super.key,
    required this.controller,
    required this.session,
  });

  @override
  State<SessionEtaCard> createState() => _SessionEtaCardState();
}

class _SessionEtaCardState extends State<SessionEtaCard> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {}); // rebuild to reflect elapsed time and geofence updates
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    
    final statusUI = getSessionStatusUI(
      sessionStatus: widget.session.sessionStatus,
      isInsideGeofence: widget.controller.isInsideGeofence,
    );

    final  duration = widget.controller.elapsedTimeFormatted; 
    "-";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(
  Icons.access_time_rounded,
  duration.toString(),
  "Duration",
  Kolors.kPrimary,
),
          VerticalDivider(color: Colors.grey.shade200, thickness: 1),
          _buildMetric(
            statusUI.icon,
            statusUI.label,
            'Status',
            statusUI.color,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
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
