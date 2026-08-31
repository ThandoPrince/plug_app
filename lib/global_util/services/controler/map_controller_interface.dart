import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract interface for map controllers
/// Allows swapping between Google Maps and fallback implementations
abstract class MapControllerInterface extends ChangeNotifier {
  /// Initialize the map with a controller
  void onMapCreated(dynamic controller);

  /// Set markers on the map
  void setMarkers(Set<Marker> markers);

  /// Add a single marker
  void addMarker(Marker marker);

  /// Remove a marker by ID
  void removeMarker(String markerId);

  /// Clear all markers
  void clearMarkers();

  /// Set polylines on the map
  void setPolylines(Set<Polyline> polylines);

  /// Add a circle
  void addCircle(Circle circle);

  /// Remove a circle
  void removeCircle(String circleId);

  /// Clear all circles
  void clearCircles();

  /// Animate camera to a position
  Future<void> animateCamera(CameraUpdate update);

  /// Move camera instantly
  void moveCamera(CameraUpdate update);

  /// Get current camera position
  CameraPosition? get currentCameraPosition;

  /// Focus on a specific location
  Future<void> focusOnLocation(LatLng location, {double zoom = 14.5});

  /// Fit bounds to show all markers
  Future<void> fitBounds(LatLngBounds bounds, {double padding = 100.0});

  /// Set map style (optional)
  Future<void> setMapStyle(String? style);

  /// Enable/disable my location layer
  void setMyLocationEnabled(bool enabled);

  /// Enable/disable zoom controls
  void setZoomControlsEnabled(bool enabled);

  /// Clean up resources
  @override
  void dispose();
}

/// Generic marker class for fallback implementation
class MapMarker {
  final String markerId;
  final LatLng position;
  final String? iconAssetPath;
  final Offset anchor;
  final VoidCallback? onTap;
  final double? rotation;
  final bool flat;
  final String? infoWindowTitle;
  final String? infoWindowSnippet;

  const MapMarker({
    required this.markerId,
    required this.position,
    this.iconAssetPath,
    this.anchor = const Offset(0.5, 0.5),
    this.onTap,
    this.rotation,
    this.flat = false,
    this.infoWindowTitle,
    this.infoWindowSnippet,
  });
}

/// Generic polyline class for fallback implementation
class MapPolyline {
  final String polylineId;
  final List<LatLng> points;
  final Color color;
  final double width;
  final List<int>? patterns;
  final bool geodesic;
  final int? startCap;
  final int? endCap;
  final int? jointType;

  const MapPolyline({
    required this.polylineId,
    required this.points,
    required this.color,
    this.width = 5.0,
    this.patterns,
    this.geodesic = true,
    this.startCap,
    this.endCap,
    this.jointType,
  });
}

/// Generic circle class for fallback implementation
class MapCircle {
  final String circleId;
  final LatLng center;
  final double radius;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const MapCircle({
    required this.circleId,
    required this.center,
    required this.radius,
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2.0,
  });
}