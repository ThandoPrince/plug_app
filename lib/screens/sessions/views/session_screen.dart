import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/rating_navigation_controller.dart';
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

  const SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late ClientSessionLocationPingController controller;

  @override
 @override
void initState() {
  super.initState();

  RatingNavigationController.reset();

  
  controller = Provider.of<ClientSessionLocationPingController>(context, listen: false);
  controller.initSession(
  id: widget.session.sessionId!,
  backendCheckinTime: widget.session.checkinTime,
);


  // Rating callback
  RatingNavigationController.onRatingAvailable = () {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RatingScreen(
          sessionId: widget.session.sessionId!,
          clientEmail: widget.session.shipment!.serviceOrdered!.client!,
        ),
      ),
    );
  };

  RatingNavigationController.checkImmediately(
    clientEmail: widget.session.shipment!.serviceOrdered!.client.toString(),
    sessionId: widget.session.sessionId!,
  );

  RatingNavigationController.startPolling(
    clientEmail: widget.session.shipment!.serviceOrdered!.client.toString(),
    sessionId: widget.session.sessionId!,
  );
}


  @override
  void dispose() {
   
    RatingNavigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<ClientSessionLocationPingController>(
        builder: (context, controller, child) {
          return WillPopScope(
            onWillPop: () async {
    goToSchedule(context);
    return false; // stop default pop
  },
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => goToSchedule(context),
  ),
                title: const Text(
                  "Active Session",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                centerTitle: true,
                backgroundColor: Kolors.kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: GeofenceMapSection(
                      controller: controller,
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
                            colors: [Kolors.kPrimary, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(32)),
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
                                margin:
                                    const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
                              ),
                              SessionEtaCard(
                                controller: controller,
                                session: widget.session,
                              ),
                              const SizedBox(height: 16),
                              if (widget.session.shipment
                                      ?.serviceOrdered
                                      ?.providerForService
                                      ?.provider !=
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
                              SessionDetailsCard(session: widget.session),
                              const SizedBox(height: 24),
                              _buildGeofenceStatus(controller),
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
      ),
    );
  }

  Widget _buildGeofenceStatus(
      ClientSessionLocationPingController controller) {
    final inside = controller.isInsideGeofence;
    final distance =
        controller.distanceMeters?.toStringAsFixed(2) ?? "-";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            size: 20,
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
