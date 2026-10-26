import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/session_by_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/views/client_pending_orders_details_screen.dart';
import 'package:flutter_application_1/screens/session_confirmation/views/session_confirmation_screen.dart';
import 'package:flutter_application_1/screens/sessions/views/session_screen.dart';
import 'package:flutter_application_1/screens/track_shipment/views/track_service_screen.dart';
import 'package:provider/provider.dart';

class ShipmentScheduleCard extends StatefulWidget {
  final ShipmentController shipmentController;

  final Shipment shipment;

  const ShipmentScheduleCard(
      {super.key, required this.shipment, required this.shipmentController});

  @override
  State<ShipmentScheduleCard> createState() => _ShipmentScheduleCardState();
}

class _ShipmentScheduleCardState extends State<ShipmentScheduleCard> {
  String _cleanProviderName(String rawName) {
    return rawName.split('-').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.shipment.serviceOrdered;
    final orderId = order?.orderId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order?.title?.toUpperCase() ?? 'SERVICE REQUEST',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey.shade900,
                          letterSpacing: -0.5,
                          // optional visual cue
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order?.serviceRequired?.serviceName ??
                            'General Service',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: widget.shipment.shipmentStatus),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1.2),
            ),

            // Details
            // Details
            _buildDetailRow(
              Icons.tag,
              orderId?.toString() ?? 'N/A',
              'Order ID',
            ),

            const SizedBox(height: 12),

            _buildDetailRow(
              Icons.event_note_rounded,
              widget.shipment.formattedDate,
              'Scheduled Date',
            ),

            const SizedBox(height: 12),

            _buildDetailRow(
              Icons.access_time_filled_rounded,
              widget.shipment.formattedTime,
              'Arrival Time',
            ),

            if (order?.providerForService != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.person_pin_rounded,
                _cleanProviderName(order!.providerForService.toString()),
                'Service Provider',
              ),
            ],

            const SizedBox(height: 24),

            // Track Service Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Kolors.kPrimary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () async {
                  final orderStatus =
                      widget.shipment.serviceOrdered?.status ?? '';
                  final shipmentStatus =
                      widget.shipment.shipmentStatus.toLowerCase();
                  final session = widget.shipmentController.sessionForShipment(
                    widget.shipment.shipmentId,
                  );
                  final routeController = GoogleShipmentRouteController(
                    shipment: widget.shipment,
                    shipmentController: widget.shipmentController,
                  );

                  /// 🚀 1. IN TRANSIT or ARRIVED → TRACK ROUTE
                  if (shipmentStatus == 'in_transit' ||
                      shipmentStatus == 'arrived' ||
                      shipmentStatus == 'rescheduled' ||
                      shipmentStatus == 'pending') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => GoogleShipmentRouteController(
                              shipment: widget.shipment,
                              shipmentController: widget.shipmentController),
                          child: TrackServiceScreen(
                            shipment: widget.shipment,
                            googleShipmentRouteController: routeController,
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  if (orderStatus == 'awaiting_confirmation') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                            create: (_) => GoogleShipmentRouteController(
                                shipment: widget.shipment,
                                shipmentController: widget.shipmentController),
                            child: ClientQrCheckinScreen(
                              shipmentId: widget.shipment.shipmentId,
                              googleShipmentRouteController: routeController,
                            )),
                      ),
                    );
                    return;
                  }

                  final sessionController =
                      context.read<SessionByShipmentController>();

                  await sessionController.fetchSession(
                    widget.shipment.shipmentId.toString(),
                  );

                  if (!context.mounted) return;

                  final activeSession = sessionController.session;

                  if (activeSession != null &&
                      activeSession.sessionStatus == 'in_session') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionScreen(
                          session: activeSession,
                          googleShipmentRouteController: routeController,
                        ),
                      ),
                    );
                    return;
                  }

                  if (session?.sessionStatus == 'awaiting_payment') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ClientQrCheckinScreen(
        shipmentId: widget.shipment.shipmentId,
        googleShipmentRouteController: routeController,
      ),
    ),
  );
  return;
}

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackServiceScreen(
                        shipment: widget.shipment,
                        googleShipmentRouteController: routeController,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'TRACK SERVICE',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text,
    String label, {
    VoidCallback? onTap,
  }) {
    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Kolors.kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Kolors.kDark),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return rowContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: rowContent,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'arrived':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
      case 'in_transit':
        color = Colors.blue;
      case 'in_session':
        color = Colors.purple;
      case 'rescheduled':
        color = Colors.amber;
      case 'delivered':
        color = Colors.blueGrey;

        break;
      default:
        color = Kolors.kPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
