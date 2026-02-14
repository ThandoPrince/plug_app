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
    this.geofenceRadiusMeters = 45,
  });

  @override
  State<GeofenceMapSection> createState() => _GeofenceMapSectionState();
}

class _GeofenceMapSectionState extends State<GeofenceMapSection> {
  HereMapController? _mapController;

  MapPolygon? _geofencePolygon;
  MapMarker? _providerMarker;

  bool _cameraInitialized = false;
  bool _polygonInitialized = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  // ===============================
  // MAP CREATED
  // ===============================
  void onMapCreated(HereMapController mapController) {
    _mapController = mapController;

    _mapController!.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (MapError? error) {
        if (error != null) {
          debugPrint("❌ Map scene load error: $error");
          return;
        }

        _initCameraOnce();
        _drawGeofenceOnce();
        _updateProviderMarker();
      },
    );
  }

  // ===============================
  // CAMERA (ONLY ONCE)
  // ===============================
  void _initCameraOnce() {
    if (_cameraInitialized || _mapController == null) return;

    final delivery = widget.session.shipment
        ?.serviceOrdered
        ?.deliveryAddress;

    if (delivery == null) return;

    final center = GeoCoordinates(
      double.tryParse(delivery.latitude.toString()) ?? 0.0,
      double.tryParse(delivery.longitude.toString()) ?? 0.0,
    );

    _mapController!.camera.lookAtPointWithMeasure(
      center,
      MapMeasure(
        MapMeasureKind.distanceInMeters,
        widget.geofenceRadiusMeters * 5,
      ),
    );

    _cameraInitialized = true;
  }

  // ===============================
  // DRAW GEOFENCE ONLY ONCE
  // ===============================
  void _drawGeofenceOnce() {
    if (_polygonInitialized || _mapController == null) return;

    final delivery = widget.session.shipment
        ?.serviceOrdered
        ?.deliveryAddress;

    if (delivery == null) return;

    final center = GeoCoordinates(
      double.tryParse(delivery.latitude.toString()) ?? 0.0,
      double.tryParse(delivery.longitude.toString()) ?? 0.0,
    );

    final points = <GeoCoordinates>[];
    const segments = 64;

    for (int i = 0; i < segments; i++) {
      final angle = (i * 360 / segments) * (pi / 180);

      final latOffset =
          widget.geofenceRadiusMeters * cos(angle) / 111320;

      final lngOffset =
          widget.geofenceRadiusMeters *
          sin(angle) /
          (111320 * cos(center.latitude * pi / 180));

      points.add(
        GeoCoordinates(
          center.latitude + latOffset,
          center.longitude + lngOffset,
        ),
      );
    }

    final outlineColor =
        widget.controller.isInsideGeofence ? Colors.green : Colors.red;

    final fillColor = widget.controller.isInsideGeofence
        ? const Color.fromARGB(64, 0, 255, 0)
        : const Color.fromARGB(64, 255, 0, 0);

    _geofencePolygon =
        MapPolygon.withOutlineColorAndOutlineWidthInPixels(
      GeoPolygon(points),
      fillColor,
      outlineColor,
      3,
    );

    _mapController!.mapScene.addMapPolygon(_geofencePolygon!);

    _polygonInitialized = true;
  }

  // ===============================
  // CONTROLLER UPDATE LISTENER
  // ===============================
  void _onControllerUpdate() {
    _updateProviderMarker();
    _updateGeofenceColorOnly();
  }

  // ===============================
  // UPDATE MARKER (NO RECREATE)
  // ===============================
  void _updateProviderMarker() {
    if (_mapController == null) return;

    final ping = widget.controller.latestPing;
    if (ping == null) return;

    final geoCoords = GeoCoordinates(
      ping.latitude ?? 0.0,
      ping.longitude ?? 0.0,
    );

    // Create marker first time
    if (_providerMarker == null) {
      _providerMarker = MapMarker(
        geoCoords,
        MapImage.withFilePathAndWidthAndHeight(
          "assets/icons/sp_marker.png",
          64,
          64,
        ),
      );

      _mapController!.mapScene.addMapMarker(_providerMarker!);
    } else {
      // 🔥 MOVE marker instead of recreating
      _providerMarker!.coordinates = geoCoords;
    }
  }

  // ===============================
  // UPDATE ONLY COLOR (NO CAMERA)
  // ===============================
  void _updateGeofenceColorOnly() {
    if (_mapController == null || _geofencePolygon == null) return;

    _mapController!.mapScene.removeMapPolygon(_geofencePolygon!);
    _polygonInitialized = false;

    _drawGeofenceOnce();
  }

  // ===============================
  // BUILD
  // ===============================
  @override
  Widget build(BuildContext context) {
    return HereMap(onMapCreated: onMapCreated);
  }
}
