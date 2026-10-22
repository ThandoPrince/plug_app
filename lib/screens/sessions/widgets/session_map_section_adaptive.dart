import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller_impl.dart';
import 'package:flutter_application_1/global_util/services/controler/fallback_map_controller_impl.dart';
import 'package:flutter_application_1/global_util/services/widgets/adaptive_map_widget.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../global_util/services/controler/map_controller_interface.dart';

/// Adaptive map section for session that works on both GMS and HMS devices
class AdaptiveSessionMapSection extends StatefulWidget {
  final GoogleShipmentRouteController controller;
  final SessionModel session;
  final double geofenceRadiusMeters;
  final GoogleMapControllerImpl? googleMapController;
  final FallbackMapControllerImpl? fallbackMapController;

  const AdaptiveSessionMapSection({
    super.key,
    required this.controller,
    required this.session,
    this.geofenceRadiusMeters = 45,
    this.googleMapController,
    this.fallbackMapController,
  });

  @override
  State<AdaptiveSessionMapSection> createState() =>
      _AdaptiveSessionMapSectionState();
}

class _AdaptiveSessionMapSectionState extends State<AdaptiveSessionMapSection> {
  GoogleMapControllerImpl? _googleController;
  FallbackMapControllerImpl? _fallbackController;
  bool _initialized = false;
  BitmapDescriptor? _providerIcon;
  BitmapDescriptor? _siteIcon;
  LatLng? _center;

  @override
  void initState() {
    super.initState();
    _googleController = widget.googleMapController ?? GoogleMapControllerImpl();
    _fallbackController =
        widget.fallbackMapController ?? FallbackMapControllerImpl();
    _initialized = true;

    _loadMarkerIcons();
    widget.controller.addListener(_onControllerUpdate);
    _initCenter();
    _syncFromController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    if (widget.googleMapController == null) {
      _googleController?.dispose();
    }
    if (widget.fallbackMapController == null) {
      _fallbackController?.dispose();
    }
    super.dispose();
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

  // =========================
  // INIT CENTER
  // =========================
  void _initCenter() {
    final delivery = widget.session.shipment?.serviceOrdered?.deliveryAddress;

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

  Circle _buildGeofenceCircle() {
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

  void _onControllerUpdate() {
    if (!mounted) return;

    _syncFromController();
    setState(() {});
  }

  void _syncFromController() {
    if (!_initialized || _center == null) return;

    final position = widget.controller.geofenceProviderLocation;
    final isInside = widget.controller.isInsideGeofence;

    // Update markers
    final providerMarker =
        position != null ? _buildProviderMarker(position) : null;
    final siteMarker = _buildSiteMarker();
    final geofenceCircle = _buildGeofenceCircle();

    // Sync to Google Maps controller
    if (_googleController != null) {
      final markers = <Marker>{siteMarker};
      if (providerMarker != null) {
        markers.add(providerMarker);
      }
      _googleController!.setMarkers(markers);

      final circles = <Circle>{geofenceCircle};
      _googleController!.clearCircles();
      for (final circle in circles) {
        _googleController!.addCircle(circle);
      }
    }

    // Sync to fallback controller
    if (_fallbackController != null) {
      final mapMarkers = <Marker>[siteMarker];
      if (providerMarker != null) {
        mapMarkers.add(providerMarker);
      }
      _fallbackController!.setMarkers(mapMarkers.toSet());

      _fallbackController!.clearCircles();
      _fallbackController!.addCircle(geofenceCircle);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initCenter();

    if (_center == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AdaptiveMapWidget(
      googleMapController: _googleController,

      initialMarkers: _buildInitialMarkers(),
      initialCircles: _buildInitialCircles(),

      initialCameraPosition: CameraPosition(
        target: _center!,
        zoom: 18,
      ),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Set<Marker> _buildInitialMarkers() {
    final markers = <Marker>{_buildSiteMarker()};
    final position = widget.controller.geofenceProviderLocation;
    if (position != null) {
      markers.add(_buildProviderMarker(position));
    }
    return markers;
  }

  Set<Circle> _buildInitialCircles() {
    return {_buildGeofenceCircle()};
  }
}
