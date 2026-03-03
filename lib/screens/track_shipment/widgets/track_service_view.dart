import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_confirm_controller.dart';
import 'package:flutter_application_1/screens/session_confirmation/views/session_confirmation_screen.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/confirm_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/eta_card.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/map_section.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/provider_card.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/shipment_details_card.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_route_controller.dart';

class TrackServiceView extends StatelessWidget {
  final Shipment shipment;

  const TrackServiceView({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShipmentRouteController(shipment: shipment),
      builder: (context, child) {
        final routeCtrl = context.watch<ShipmentRouteController>();
        final provider = shipment.serviceOrdered?.providerForService?.provider;
        final service = shipment.serviceOrdered;

        /// ---------------------------
        /// CONFIRM SERVICE DIALOG LOGIC
        /// ---------------------------
        void confirmService(BuildContext parentContext, Shipment shipment) {
          showDialog(
            context: parentContext,
            builder: (dialogContext) {
              final controller = Provider.of<ShipmentConfirmController>(
                dialogContext,
                listen: false,
              );

              return AlertDialog(
                title: const Text("Confirm Arrival"),
                content: const Text(
                  "Please confirm that the Service Provider has arrived.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext); // Close dialog first

                      // Call the API
                      await controller.confirmShipment(shipment.shipmentId);

                      final error = controller.errorMessage;
                      final response = controller.response;

                      // 🚫 Stop if error exists and it's NOT "already delivered"
                      if (error != null &&
                          !error.toLowerCase().contains("already delivered")) {
                        FlushbarService.error(parentContext, error);
                        return; // STOP navigation
                      }

                      // ✅ Proceed if success OR error is "already delivered"
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (_) => ClientQrCheckinScreen(
                              shipmentId: shipment.shipmentId,
                            ),
                          ),
                        );
                      });
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              );
            },
          );
        }

        /// ---------------------------
        /// UI
        /// ---------------------------
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              /// 🗺️ MAP + SHEET in Column
              Column(
                children: [
                  Expanded(child: MapSection(routeController: routeCtrl)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45),
                ],
              ),

              /// 📦 DRAGGABLE DETAILS
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
                        children: [
                          /// Pull handle
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          /// ETA
                          EtaCard(
                              routeController: routeCtrl, shipment: shipment),
                          const SizedBox(height: 16),

                          /// Provider
                          if (provider != null) ...[
                            ProviderCard(provider: provider,
                            service: service
                            ),
                            const SizedBox(height: 16),
                          ],

                          /// Shipment details
                          ShipmentDetailsCard(shipment: shipment),

                          /// Confirm button if status is arrived
                          if (shipment.shipmentStatus == "arrived") ...[
                            const SizedBox(height: 24),
                            ConfirmServiceButton(
                              onConfirm: () =>
                                  confirmService(context, shipment),
                            ),
                          ],

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
}
