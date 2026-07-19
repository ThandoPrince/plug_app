import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/screens/ratings/views/ratings_screen.dart';
import 'package:flutter_application_1/screens/schedule/widgets/go_to_schedule_helper.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_details_card.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_eta_card.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_map_section.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_provider_card.dart';
import 'package:provider/provider.dart';

class SessionScreen extends StatefulWidget {
  final SessionModel session;
  final GoogleShipmentRouteController googleShipmentRouteController;

  const SessionScreen(
      {super.key,
      required this.session,
      required this.googleShipmentRouteController});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {


  late ShipmentController shipmentController;
  late VoidCallback shipmentListener;
  late ClientSessionLocationPingController pingController;
  

  bool _navigated = false;

  @override
void initState() {
  super.initState();

   final shipmentId = widget.session.shipment?.shipmentId;
  if (shipmentId != null) {
    widget.googleShipmentRouteController.startRealtime(shipmentId);
  }

  
  pingController = context.read<ClientSessionLocationPingController>();

  
    _initializeSession();

    shipmentController = context.read<ShipmentController>();

  shipmentListener = () {
    if (!mounted || _navigated) return;

    if (shipmentController.completedSessionShipmentId !=
        widget.session.shipment!.shipmentId) {
      return;
    }

    _navigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RatingScreen(
          sessionId: widget.session.sessionId!,
         
        ),
      ),
    );
  };

  shipmentController.addListener(shipmentListener);
}

Future<void> _initializeSession() async {
  await pingController.initSession(
    id: widget.session.sessionId!,
    backendCheckinTime: widget.session.checkinTime,
  );

  if (!mounted) return;

  widget.googleShipmentRouteController.setInitialPing(
    pingController.latestPing,
  );

  widget.googleShipmentRouteController.startElapsedTimer(
  widget.session.checkinTime!,
);
}



  @override
  void dispose() {
    shipmentController.removeListener(shipmentListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.googleShipmentRouteController,
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            goToSchedule(context);
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Kolors.kPrimary,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Active Session",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => goToSchedule(context),
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: GeofenceMapSection(
                    controller: widget.googleShipmentRouteController,
                    session: widget.session,
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.45,
                  maxChildSize: 0.75,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Kolors.kPrimary,
                            Kolors.kPrimary,
                            Kolors.kWhite
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SessionEtaCard(
                              controller: widget.googleShipmentRouteController,
                              session: widget.session,
                            ),
                            const SizedBox(height: 16),
                            if (widget.session.shipment?.serviceOrdered
                                    ?.providerForService?.provider !=
                                null) ...[
                              SessionProviderCard(
                                provider: widget
                                    .session
                                    .shipment!
                                    .serviceOrdered!
                                    .providerForService!
                                    .provider,
                              ),
                              const SizedBox(height: 16),
                            ],
                            SessionDetailsCard(
                              session: widget.session,
                            ),
                            const SizedBox(height: 24),
                            _buildGeofenceStatus(widget.googleShipmentRouteController),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeofenceStatus(GoogleShipmentRouteController controller) {
    final inside = controller.isInsideGeofence;
    final distance =
      controller.distanceFromSiteMeters?.toStringAsFixed(2) ?? "-";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            inside ? Icons.check_circle : Icons.warning,
            color: inside ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(
            inside
                ? "Inside Geofence ($distance m)"
                : "Outside Geofence ($distance m)",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
