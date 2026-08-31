import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_controller_interface.dart';

/// Fallback map implementation for devices without Google Maps
/// Uses a static map image with basic interaction
class FallbackMapControllerImpl extends MapControllerInterface {
  final List<MapMarker> _markers = [];
  final List<MapPolyline> _polylines = [];
  final List<MapCircle> _circles = [];
  CameraPosition? _currentCameraPosition;
  LatLng? _center;
  double _zoom = 14.5;

  @override
  void onMapCreated(dynamic controller) {
    // No-op for fallback implementation
    notifyListeners();
  }

  @override
  void setMarkers(Set<Marker> markers) {
    _markers.clear();
    for (final marker in markers) {
      _markers.add(MapMarker(
        markerId: marker.markerId.value,
        position: marker.position,
        anchor: marker.anchor,
        onTap: marker.onTap,
        rotation: marker.rotation,
        flat: marker.flat,
        infoWindowTitle: marker.infoWindow.title,
        infoWindowSnippet: marker.infoWindow.snippet,
      ));
    }
    notifyListeners();
  }

  @override
  void addMarker(Marker marker) {
    _markers.add(MapMarker(
      markerId: marker.markerId.value,
      position: marker.position,
      anchor: marker.anchor,
      onTap: marker.onTap,
      rotation: marker.rotation,
      flat: marker.flat,
      infoWindowTitle: marker.infoWindow.title,
      infoWindowSnippet: marker.infoWindow.snippet,
    ));
    notifyListeners();
  }

  @override
  void removeMarker(String markerId) {
    _markers.removeWhere((m) => m.markerId == markerId);
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
    for (final polyline in polylines) {
      _polylines.add(MapPolyline(
        polylineId: polyline.polylineId.value,
        points: polyline.points,
        color: polyline.color,
        width: polyline.width.toDouble(),
        patterns: null,
        geodesic: polyline.geodesic,
      ));
    }
    notifyListeners();
  }

  @override
  void addCircle(Circle circle) {
    _circles.add(MapCircle(
      circleId: circle.circleId.value,
      center: circle.center,
      radius: circle.radius,
      fillColor: circle.fillColor,
      strokeColor: circle.strokeColor,
      strokeWidth: circle.strokeWidth.toDouble(),
    ));
    notifyListeners();
  }

  @override
  void removeCircle(String circleId) {
    _circles.removeWhere((c) => c.circleId == circleId);
    notifyListeners();
  }

  @override
  void clearCircles() {
    _circles.clear();
    notifyListeners();
  }

  @override
  Future<void> animateCamera(CameraUpdate update) async {
    // CameraUpdate does not expose its operation through the public API.
    // The fallback implementation cannot apply platform camera updates.
    notifyListeners();
  }

  @override
  void moveCamera(CameraUpdate update) {
    animateCamera(update);
  }

  @override
  CameraPosition? get currentCameraPosition => _currentCameraPosition;

  @override
  Future<void> focusOnLocation(LatLng location, {double zoom = 14.5}) async {
    _center = location;
    _zoom = zoom;
    _currentCameraPosition = CameraPosition(target: location, zoom: zoom);
    notifyListeners();
  }

  @override
  Future<void> fitBounds(LatLngBounds bounds, {double padding = 100.0}) async {
    _center = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
    _currentCameraPosition = CameraPosition(target: _center!, zoom: _zoom);
    notifyListeners();
  }

  @override
  Future<void> setMapStyle(String? style) async {
    // No-op for fallback
  }

  @override
  void setMyLocationEnabled(bool enabled) {
    // No-op for fallback
  }

  @override
  void setZoomControlsEnabled(bool enabled) {
    // No-op for fallback
  }

  /// Get markers for the fallback map widget
  List<MapMarker> get markers => List.unmodifiable(_markers);

  /// Get polylines for the fallback map widget
  List<MapPolyline> get polylines => List.unmodifiable(_polylines);

  /// Get circles for the fallback map widget
  List<MapCircle> get circles => List.unmodifiable(_circles);

  /// Get center for static map
  LatLng get center => _center ?? const LatLng(-26.2041, 28.0473);

  /// Get zoom level
  double get zoom => _zoom;

  @override
  void dispose() {
    _markers.clear();
    _polylines.clear();
    _circles.clear();
    super.dispose();
  }
}
