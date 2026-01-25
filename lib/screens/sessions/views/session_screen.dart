import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_details_card.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_eta_card.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_map_section.dart';
import 'package:flutter_application_1/screens/sessions/widgets/session_provider_card.dart';
import 'package:provider/provider.dart';

class SessionScreen extends StatelessWidget {
  final SessionModel session;

  const SessionScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ClientSessionLocationPingController(sessionId: session.sessionId!),
      builder: (context, child) {
        final controller = context.watch<ClientSessionLocationPingController>();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
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
              // Full-screen map
              Positioned.fill(
                child: GeofenceMapSection(
                  controller: controller,
                  session: session,
                ),
              ),

              // Draggable sheet
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
                          horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pull handle
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // ETA + Duration
                          SessionEtaCard(
                            controller: controller,
                            session: session,
                          ),
                          const SizedBox(height: 16),

                          // Provider Card
                          if (session.shipment?.serviceOrdered
                                  ?.providerForService?.provider !=
                              null) ...[
                            SessionProviderCard(
                              provider: session.shipment!.serviceOrdered!
                                  .providerForService!.provider!,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Session Details Card
                          SessionDetailsCard(session: session),
                          const SizedBox(height: 24),

                          // Distance / Geofence Status
                          _buildGeofenceStatus(controller),
                          const SizedBox(height: 24),

                          // End Session Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                await controller.endSession();
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                "END SESSION",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeofenceStatus(ClientSessionLocationPingController controller) {
    final inside = controller.isInsideGeofence;
    final distance = controller.distanceMeters?.toStringAsFixed(2) ?? "-";

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
              offset: const Offset(0, 4))
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
