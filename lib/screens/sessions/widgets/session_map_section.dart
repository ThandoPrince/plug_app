import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';

class GeofenceMapSection extends StatefulWidget {
  final GoogleShipmentRouteController controller;
  final SessionModel session;
  final double geofenceRadiusMeters;

  const GeofenceMapSection({
    super.key,
    required this.controller,
    required this.session,
    this.geofenceRadiusMeters = 45,
  });

  @override
  State<GeofenceMapSection> createState() => _GeofenceMapSectionState();
}

class _GeofenceMapSectionState extends State<GeofenceMapSection> {
  GoogleMapController? _mapController;

  LatLng? _center;
  BitmapDescriptor? _providerIcon;
BitmapDescriptor? _siteIcon;

  bool _cameraInitialized = false;

  Marker? _providerMarker;
  Circle? _geofenceCircle;

  @override
void initState() {
  super.initState();

  widget.controller.addListener(_onControllerUpdate);

  _loadMarkerIcons();
}

Future<void> _loadMarkerIcons() async {
  _providerIcon = await BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(64, 64)),
    "assets/icons/sp_marker.png",
  );

  _siteIcon = await BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(64, 64)),
    "assets/icons/default_marker.png",
  );

  if (mounted) {
    setState(() {});
  }
}

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _mapController?.dispose();
    super.dispose();
  }

  // =========================
  // INIT CENTER
  // =========================
  void _initCenter() {
    final delivery =
        widget.session.shipment?.serviceOrdered?.deliveryAddress;

    if (delivery == null) return;

    _center = LatLng(
      double.tryParse(delivery.latitude.toString()) ?? 0.0,
      double.tryParse(delivery.longitude.toString()) ?? 0.0,
    );
  }

  Marker _buildProviderMarker(LatLng position) {
  return Marker(
    markerId: const MarkerId("provider"),
    position: position,
    icon: _providerIcon ?? BitmapDescriptor.defaultMarker,
    anchor: const Offset(0.5, 0.5),
  );
}

Marker _buildSiteMarker() {
  return Marker(
    markerId: const MarkerId("site"),
    position: _center!,
    icon: _siteIcon ?? BitmapDescriptor.defaultMarker,
    anchor: const Offset(0.5, 0.5),
  );
}

  // =========================
  // CAMERA ONCE
  // =========================
  void _moveCameraOnce() {
    if (_cameraInitialized || _mapController == null || _center == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_center!, 18),
    );

    _cameraInitialized = true;
  }

  // =========================
  // CONTROLLER UPDATE
  // =========================
  void _onControllerUpdate() {
    if (!mounted) return;

    final position = widget.controller.geofenceProviderLocation;

if (position != null) {
  _providerMarker = _buildProviderMarker(position);
}

    setState(() {});
  }

  // =========================
  // GEOFENCE CIRCLE
  // =========================
  Circle _buildCircle() {
    final isInside = widget.controller.isInsideGeofence;

    return Circle(
      circleId: const CircleId("geofence"),
      center: _center!,
      radius: widget.geofenceRadiusMeters,
      fillColor: (isInside ? Colors.green : Colors.red).withOpacity(0.25),
      strokeColor: isInside ? Colors.green : Colors.red,
      strokeWidth: 2,
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    _initCenter();

    if (_center == null) {
      return const Center(child: CircularProgressIndicator());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveCameraOnce();
    });

    final Set<Marker> markers = {
  _buildSiteMarker(),
  if (_providerMarker != null) _providerMarker!,
};

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _center!,
        zoom: 18,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _moveCameraOnce();
      },
      markers: markers,
      circles: {_buildCircle()},
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}