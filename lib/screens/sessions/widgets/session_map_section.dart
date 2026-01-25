import 'dart:math';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';

class GeofenceMapSection extends StatefulWidget {
  final ClientSessionLocationPingController controller;
  final SessionModel session;
  final double geofenceRadiusMeters;

  const GeofenceMapSection({
    super.key,
    required this.controller,
    required this.session,
    this.geofenceRadiusMeters = 30,
  });

  @override
  State<GeofenceMapSection> createState() => _GeofenceMapSectionState();
}

class _GeofenceMapSectionState extends State<GeofenceMapSection> {
  late HereMapController _mapController;
  MapPolygon? _geofencePolygon;
  MapMarker? _providerMarker;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateProviderMarker);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateProviderMarker);
    super.dispose();
  }

  void onMapCreated(HereMapController mapController) {
    _mapController = mapController;

    _mapController.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (MapError? error) {
        if (error != null) {
          debugPrint("❌ Map scene load error: ${error.toString()}");
          return;
        }

        _drawGeofenceCircle();
        _updateProviderMarker();
      },
    );
  }


  void _drawGeofenceCircle() {
    final delivery = widget.session.shipment?.serviceOrdered?.deliveryAddress;
    if (delivery == null) return;

    final center = GeoCoordinates(
      double.tryParse(delivery.latitude.toString()) ?? 0.0,
      double.tryParse(delivery.longitude.toString()) ?? 0.0,
    );

    // Generate points around a circle
    final points = <GeoCoordinates>[];
    final segments = 64;
    for (int i = 0; i < segments; i++) {
      final angle = (i * 360 / segments) * (pi / 180);
      final latOffset = widget.geofenceRadiusMeters * cos(angle) / 111320;
      final lngOffset = widget.geofenceRadiusMeters * sin(angle) / (111320 * cos(center.latitude * pi / 180));
      points.add(GeoCoordinates(center.latitude + latOffset, center.longitude + lngOffset));
    }

    // Remove previous polygon
    if (_geofencePolygon != null) {
      _mapController.mapScene.removeMapPolygon(_geofencePolygon!);
      _geofencePolygon = null;
    }

    final outlineColor = widget.controller.isInsideGeofence ? Colors.green : Colors.red;
    final fillColor = widget.controller.isInsideGeofence
        ? const Color.fromARGB(64, 0, 255, 0)
        : const Color.fromARGB(64, 255, 0, 0);

    _geofencePolygon = MapPolygon.withOutlineColorAndOutlineWidthInPixels(
      GeoPolygon(points),
      fillColor,
      outlineColor,
      3,
    );

    _mapController.mapScene.addMapPolygon(_geofencePolygon!);

    // Center camera on geofence
    _mapController.camera.lookAtPointWithMeasure(
      center,
      MapMeasure(MapMeasureKind.distanceInMeters, widget.geofenceRadiusMeters * 5),
    );
  }


  void _updateProviderMarker() {
    final ping = widget.controller.latestPing;
    if (ping == null) return;

    final geoCoords = GeoCoordinates(ping.latitude ?? 0.0, ping.longitude ?? 0.0);

    // Remove previous marker
    if (_providerMarker != null) {
      _mapController.mapScene.removeMapMarker(_providerMarker!);
      _providerMarker = null;
    }

    _providerMarker = MapMarker(
      geoCoords,
      MapImage.withFilePathAndWidthAndHeight("assets/provider_marker.png", 64, 64),
    );

    _mapController.mapScene.addMapMarker(_providerMarker!);

    // Update geofence color dynamically
    _drawGeofenceCircle();
  }

  @override
  Widget build(BuildContext context) {
    return HereMap(onMapCreated: onMapCreated);
  }
}
