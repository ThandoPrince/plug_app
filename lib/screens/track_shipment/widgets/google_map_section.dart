import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';

class GoogleMapSection extends StatefulWidget {
  final GoogleShipmentRouteController routeController;

  const GoogleMapSection({
    super.key,
    required this.routeController,
  });

  @override
  State<GoogleMapSection> createState() => _GoogleMapSectionState();
}

class _GoogleMapSectionState extends State<GoogleMapSection> {
  GoogleMapController? _mapController;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    widget.routeController.setMapController(controller);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.routeController;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: onMapCreated,

          initialCameraPosition: const CameraPosition(
            target: LatLng(-26.2041, 28.0473),
            zoom: 12,
          ),

          myLocationEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,

          markers: ctrl.markers,
          polylines: ctrl.polylines,

          onCameraMoveStarted: ctrl.onUserInteraction,
          onTap: (_) => ctrl.onUserInteraction(),
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: ctrl.recenter,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}