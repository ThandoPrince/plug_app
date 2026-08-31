import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_controller_interface.dart';

/// Google Maps implementation of the MapControllerInterface
class GoogleMapControllerImpl extends MapControllerInterface {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  CameraPosition? _currentCameraPosition;

  @override
  void onMapCreated(dynamic controller) {
    if (controller is GoogleMapController) {
      _mapController = controller;
      notifyListeners();
    }
  }

  @override
  void setMarkers(Set<Marker> markers) {
    _markers.clear();
    _markers.addAll(markers);
    notifyListeners();
  }

  @override
  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  @override
  void removeMarker(String markerId) {
    _markers.removeWhere((m) => m.markerId.value == markerId);
    notifyListeners();
  }

  @override
  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  @override
  void setPolylines(Set<Polyline> polylines) {
    _polylines.clear();
    _polylines.addAll(polylines);
    notifyListeners();
  }

  @override
  void addCircle(Circle circle) {
    _circles.add(circle);
    notifyListeners();
  }

  @override
  void removeCircle(String circleId) {
    _circles.removeWhere((c) => c.circleId.value == circleId);
    notifyListeners();
  }

  @override
  void clearCircles() {
    _circles.clear();
    notifyListeners();
  }

  @override
  Future<void> animateCamera(CameraUpdate update) async {
    if (_mapController == null) return;

    try {
      await _mapController!.animateCamera(update);
    } catch (e) {
      debugPrint('GoogleMapControllerImpl: animateCamera failed: $e');
    }
  }

  @override
  void moveCamera(CameraUpdate update) {
    if (_mapController == null) return;

    try {
      _mapController!.moveCamera(update);
    } catch (e) {
      debugPrint('GoogleMapControllerImpl: moveCamera failed: $e');
    }
  }

  @override
  CameraPosition? get currentCameraPosition => _currentCameraPosition;

  @override
  Future<void> focusOnLocation(LatLng location, {double zoom = 14.5}) async {
    await animateCamera(CameraUpdate.newLatLngZoom(location, zoom));
  }

  @override
  Future<void> fitBounds(LatLngBounds bounds, {double padding = 100.0}) async {
    await animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }

  @override
  Future<void> setMapStyle(String? style) async {
    if (_mapController == null || style == null) return;
    try {
      await _mapController!.setMapStyle(style);
    } catch (e) {
      debugPrint('GoogleMapControllerImpl: setMapStyle failed: $e');
    }
  }

  @override
  void setMyLocationEnabled(bool enabled) {
    // This is handled by the GoogleMap widget directly
    notifyListeners();
  }

  @override
  void setZoomControlsEnabled(bool enabled) {
    // This is handled by the GoogleMap widget directly
    notifyListeners();
  }

  /// Get markers for the GoogleMap widget
  Set<Marker> get markers => _markers;

  /// Get polylines for the GoogleMap widget
  Set<Polyline> get polylines => _polylines;

  /// Get circles for the GoogleMap widget
  Set<Circle> get circles => _circles;

  @override
  void dispose() {
    _markers.clear();
    _polylines.clear();
    _circles.clear();
    _mapController = null;
    super.dispose();
  }
}
