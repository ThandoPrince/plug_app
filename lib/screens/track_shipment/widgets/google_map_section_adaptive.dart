import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller_impl.dart';
import 'package:flutter_application_1/global_util/services/controler/fallback_map_controller_impl.dart';
import 'package:flutter_application_1/global_util/services/widgets/adaptive_map_widget.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';

/// Adaptive map section for track service that works on both GMS and HMS devices
class AdaptiveMapSection extends StatefulWidget {
  final GoogleShipmentRouteController routeController;
  final GoogleMapControllerImpl? googleMapController;
  final FallbackMapControllerImpl? fallbackMapController;

  const AdaptiveMapSection({
    super.key,
    required this.routeController,
    this.googleMapController,
    this.fallbackMapController,
  });

  @override
  State<AdaptiveMapSection> createState() => _AdaptiveMapSectionState();
}

class _AdaptiveMapSectionState extends State<AdaptiveMapSection> {
  GoogleMapControllerImpl? _googleController;
  FallbackMapControllerImpl? _fallbackController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _googleController = widget.googleMapController ?? GoogleMapControllerImpl();
    _fallbackController =
        widget.fallbackMapController ?? FallbackMapControllerImpl();
    _initialized = true;

    // Listen to route controller changes and sync to our controllers
    widget.routeController.addListener(_syncFromRouteController);
    _syncFromRouteController();
  }

  @override
  void dispose() {
    widget.routeController.removeListener(_syncFromRouteController);
    if (widget.googleMapController == null) {
      _googleController?.dispose();
    }
    if (widget.fallbackMapController == null) {
      _fallbackController?.dispose();
    }
    super.dispose();
  }

  void _syncFromRouteController() {
    if (!_initialized) return;

    final routeCtrl = widget.routeController;

    // Sync markers
    if (_googleController != null) {
      _googleController!.setMarkers(routeCtrl.markers);
      _googleController!.setPolylines(routeCtrl.polylines);
      _googleController!.clearCircles();
      // Note: circles would need to be added if routeCtrl has them
    }

    if (_fallbackController != null) {
      _fallbackController!.setMarkers(routeCtrl.markers);
      _fallbackController!.setPolylines(routeCtrl.polylines);
      _fallbackController!.clearCircles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.routeController,
      builder: (context, _) {
        final ctrl = widget.routeController;
        final hasProviderPosition = ctrl.currentProviderPosition != null;

        // Determine initial camera position
        LatLng initialTarget = GoogleMapMarkerController.fallbackCenter;
        if (hasProviderPosition) {
          initialTarget = ctrl.currentProviderPosition!;
        } else if (ctrl.markers.isNotEmpty) {
          initialTarget = ctrl.markers.first.position;
        }

        return AdaptiveMapWidget(
  googleMapController: _googleController,
  fallbackMapController: _fallbackController,
  initialMarkers: ctrl.markers,
  googleMapsApiKey: dotenv.env['GOOGLE_API_KEY'],
  initialPolylines: ctrl.polylines,
  onMapCreated: (controller) => widget.routeController.setMapController(controller),
  initialCameraPosition: CameraPosition(
    target: initialTarget,
    zoom: 12,
  ),
  myLocationEnabled: true,
  zoomControlsEnabled: false,
  mapToolbarEnabled: false,
);
      },
    );
  }
}
