import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/shimmers/track_service_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/client_order_realtime_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_confirm_controller.dart';
import 'package:flutter_application_1/screens/schedule/widgets/shipment_action_dialogs.dart';

import 'package:flutter_application_1/screens/session_confirmation/views/session_confirmation_screen.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/confirm_button.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/google_map_section_adaptive.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller_impl.dart';
import 'package:flutter_application_1/global_util/services/controler/fallback_map_controller_impl.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/provider_card.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/shipment_details_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/eta_card.dart';


import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';

class TrackServiceView extends StatefulWidget {
  final Shipment shipment;
  final GoogleShipmentRouteController googleShipmentRouteController;

  const TrackServiceView({
    super.key,
    required this.shipment,
    required this.googleShipmentRouteController,
  });

  @override
  State<TrackServiceView> createState() => _TrackServiceViewState();
}

class _TrackServiceViewState extends State<TrackServiceView> {
  late GoogleMapControllerImpl _googleMapController;
  late FallbackMapControllerImpl _fallbackMapController;
  late ClientOrderRealtimeController _realtime;
  bool _controllersInitialized = false;


Function(Map<String, dynamic>)? _previousStatusHandler;
  @override
  void initState() {
    super.initState();
    
    _googleMapController = GoogleMapControllerImpl();
    _fallbackMapController = FallbackMapControllerImpl();
    _controllersInitialized = true;
    _realtime = context.read<ClientOrderRealtimeController>();
_previousStatusHandler = _realtime.onShipmentStatusUpdated;

_realtime.onShipmentStatusUpdated = (data) {
  _previousStatusHandler?.call(data); // keep any existing behaviour
  final id = int.tryParse(data['shipment_id']?.toString() ?? '');
  if (id == widget.shipment.shipmentId) {
    widget.googleShipmentRouteController.applyStatusUpdate(data);
  }
};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.googleShipmentRouteController.startRealtime(
        widget.shipment.shipmentId,
      );
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    _realtime.onShipmentStatusUpdated = _previousStatusHandler;
    _fallbackMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.googleShipmentRouteController,
      builder: (context, child) {
        final routeCtrl = widget.googleShipmentRouteController;

        // Only block the whole screen behind a spinner/error state when
        // there's truly nothing to show yet (no route ever loaded). Once
        // `hasRoute` is true, a transient reload/error afterwards (a
        // background refetch, a socket hiccup, navigating back to this
        // screen, etc.) must NOT swap the whole Scaffold out again — that
        // was causing the loading/error screen to flash back in. From
        // that point on we always render the real content and surface
        // any problem inline instead (see the banner further down).
        final hasRoute = routeCtrl.hasRoute;

        if (routeCtrl.isLoading && !hasRoute) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                // Keep the map area visible.
                AdaptiveMapSection(
  routeController: routeCtrl,
  googleMapController: _googleMapController,
  fallbackMapController: _fallbackMapController,
),

                // Skeleton bottom sheet.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: const TrackServiceSkeleton(),
                  ),
                ),
              ],
            ),
          );
        }

        if (routeCtrl.errorMessage != null && !hasRoute) {
          if (kDebugMode) {
            debugPrint(
              "GoogleShipmentRouteController Error: ${routeCtrl.errorMessage}",
            );
          }

          return Scaffold(
            body: _buildState(
              icon: Icons.cloud_off_outlined,
              title: "Unable to load tracking",
              subtitle: routeCtrl.errorMessage!,
            ),
          );
        }

        final provider =
            widget.shipment.serviceOrdered?.providerForService?.provider;

        final service = widget.shipment.serviceOrdered;

        void confirmService(
          BuildContext parentContext,
          Shipment shipment,
        ) {
          showDialog(
            context: parentContext,
            barrierDismissible: false,
            builder: (dialogContext) {
              final controller = Provider.of<ShipmentConfirmController>(
                dialogContext,
                listen: false,
              );

              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  "Confirm Arrival",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  "Confirm that the Service Provider has arrived at the location.",
                  textAlign: TextAlign.center,
                ),
                actions: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GradientBtn(
                        text: "CONFIRM ARRIVAL",
                        btnColor: Kolors.kPrimary,
                        textColor: Kolors.kWhite,
                        btnHieght: 50.h,
                        btnWidth: double.infinity,
                        radius: 12,
                        onTap: () async {
                          Navigator.of(dialogContext).pop();

                          await controller.confirmShipment(
                            shipment.shipmentId,
                          );

                          final error = controller.errorMessage;

                          if (!parentContext.mounted) return;

                          if (error != null &&
                              !error.toLowerCase().contains(
                                    "already delivered",
                                  )) {
                            FlushbarService.error(
                              parentContext,
                              error,
                            );
                            return;
                          }

                          Navigator.push(
                            parentContext,
                            MaterialPageRoute(
                              builder: (_) => ClientQrCheckinScreen(
                                shipmentId: shipment.shipmentId,
                                googleShipmentRouteController:
                                    widget.googleShipmentRouteController,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                      GradientBtn(
                        text: "CANCEL",
                        btnColor: Colors.grey.shade300,
                        textColor: Colors.black,
                        btnHieght: 50.h,
                        btnWidth: double.infinity,
                        radius: 12,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              /// 🗺️ MAP
              Column(
                children: [
                  Expanded(
                    child: AdaptiveMapSection(
                      routeController: routeCtrl,
                      googleMapController: _googleMapController,
                      fallbackMapController: _fallbackMapController,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                  ),
                ],
              ),

              /// 📦 DRAGGABLE SHEET
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
                          Kolors.kWhite,
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

                          // Transient-error banner: shown only when an
                          // error arrives AFTER we already had a route
                          // loaded once (e.g. a failed background
                          // reconnect). This keeps the map and sheet
                          // visible instead of tearing the whole screen
                          // down, which is what caused the flicker on
                          // navigating back.
                          if (routeCtrl.errorMessage != null && hasRoute) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cloud_off_outlined,
                                    size: 18,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      routeCtrl.errorMessage!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          /// ETA
                          EtaCard(
                            routeController: routeCtrl,
                            shipment: widget.shipment,
                          ),

                          const SizedBox(height: 16),

                          /// Provider
                          if (provider != null)
                            ProviderCard(
                              provider: provider,
                              service: service,
                            ),

                          const SizedBox(height: 16),

                          /// Shipment details
                          ShipmentDetailsCard(
                            shipment: widget.shipment,
                          ),

                          /// Confirm (UNCHANGED)
                          if (routeCtrl.shipmentStatus.trim().toLowerCase() == "arrived") ...[
                            const SizedBox(height: 24),
                            ConfirmServiceButton(
                              onConfirm: () => confirmService(
                                context,
                                widget.shipment,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

/// Cancel — same dialog/behavior as ScheduledShipmentsScreen
GradientBtn(
  text: "CANCEL SHIPMENT",
  btnColor: Colors.red,
  textColor: Colors.white,
  btnHieght: 50.h,
                        btnWidth: double.infinity,
                        radius: 12,
  onTap: () => showShipmentCancelDialog(
    context: context,
    shipmentId: widget.shipment.shipmentId,
    onCancelled: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    },
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
}

Widget _buildState({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 72,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ),
  );
}