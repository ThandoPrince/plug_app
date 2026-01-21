import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as here;

import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_1/const/services/booking_services/shipment_route_api.dart';

/// -----------------------------
/// SHIPMENT ROUTE CONTROLLER
/// -----------------------------
class ShipmentRouteController extends ChangeNotifier {
  final Shipment shipment;
  Timer? _pollingTimer;
bool _isPolling = false;
bool _followProvider = true; 
final bool _isFollowing = true;
bool get isFollowing => _followProvider;
GeoCoordinates? _currentProviderPosition;

  ShipmentRouteModel? activeRoute;
  bool isLoading = false;
  String? errorMessage;

  HereMapController? _mapController;

  MapMarker? _originMarker;
  MapMarker? _destinationMarker;
  MapPolyline? _routePolyline;
  MapImage? _originImage;
  MapImage? _destinationImage;

  here.Route? _currentRoute;

  ShipmentRouteController({required this.shipment});

  // -----------------------------
  // SET MAP CONTROLLER
  // -----------------------------
  void setMapController(HereMapController controller) async {
    _mapController = controller;
    await _loadMarkerImages();
    await loadShipmentRoutes();
  }

  // Optional method to support previous `loadShipmentRoutesAndFocus` call
  Future<void> loadShipmentRoutesAndFocus(
    HereMapController controller, {
    double topPaddingFraction = 0.45,
  }) async {
    await loadShipmentRoutes(topPaddingFraction: topPaddingFraction);
    startPolling();
    _mapController = controller;
    _mapController!.camera.principalPoint = Point2D(0.5, 0.30);
    await _loadMarkerImages();
    await loadShipmentRoutes(topPaddingFraction: topPaddingFraction);

    
  }

  void enableFollow() {
  _followProvider = true;
}

void disableFollow() {
  _followProvider = false;
}


void startPolling({Duration interval = const Duration(seconds: 6)}) {
  if (_isPolling) return;

  _isPolling = true;

  _pollingTimer = Timer.periodic(interval, (_) async {
    await _pollShipmentRouteUpdate();
  });
}


void stopPolling() {
  _pollingTimer?.cancel();
  _pollingTimer = null;
  _isPolling = false;
}

Future<void> _pollShipmentRouteUpdate() async {
  if (_mapController == null || shipment.shipmentId == 0) return;

  try {
    final routes =
        await ShipmentRouteApi.fetchRoutesByShipment(shipment.shipmentId);
    if (routes.isEmpty) return;

    final latestRoute = routes.last;

    // Ignore if same route
    if (activeRoute?.routeId == latestRoute.routeId &&
        listEquals(
          activeRoute?.decodedPolyline,
          latestRoute.decodedPolyline,
        )) {
      return;
    }

    activeRoute = latestRoute;

    final vertices = latestRoute.decodedPolyline;
    if (vertices.isEmpty) return;

    // Update polyline
    _drawRoutePolyline(vertices);

    // Update provider marker (last point)
    await _addOriginMarker(vertices.first);
    await _addDestinationMarker(vertices.last);

    // FOLLOW MODE
    if (_followProvider) {
      followProvider(
        position: vertices.last,
        bearing: _calculateBearing(vertices),
      );
    }

    notifyListeners();
  } catch (e) {
    if (kDebugMode) {
      print("🔁 Polling error: $e");
    }
  }
}

double _calculateBearing(List<GeoCoordinates> points) {
  if (points.length < 2) return 0;

  final p1 = points[points.length - 2];
  final p2 = points.last;

  final dLon = (p2.longitude - p1.longitude) * pi / 180;
  final lat1 = p1.latitude * pi / 180;
  final lat2 = p2.latitude * pi / 180;

  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) -
      sin(lat1) * cos(lat2) * cos(dLon);

  final bearing = atan2(y, x);
  return (bearing * 180 / pi + 360) % 360;
}




  Future<void> _loadMarkerImages() async {
    if (_mapController == null) return;

    _originImage ??= MapImage.withFilePathAndWidthAndHeight(
      "assets/icons/sp_marker.png",
      64,
      64,
    );

    _destinationImage ??= MapImage.withFilePathAndWidthAndHeight(
      "assets/icons/default_marker.png",
      64,
      64,
    );
  }

  void recenterOnProvider() {
  if (_currentProviderPosition != null) {
    followProvider(position: _currentProviderPosition!);
    _followProvider = true;
  }
}

  void followProvider({required GeoCoordinates position, double bearing = 0}) {
    _currentProviderPosition = position;
    if (_mapController == null || !_isFollowing) return;

    _mapController!.camera.lookAtPointWithGeoOrientationAndMeasure(
      position,
      GeoOrientationUpdate(50, bearing),
      MapMeasure(MapMeasureKind.distanceInMeters, 1200),
    );
  }


  // -----------------------------
  // LOAD SHIPMENT ROUTES
  // -----------------------------
  Future<void> loadShipmentRoutes({double topPaddingFraction = 0.40}) async {
    if (_mapController == null || shipment.shipmentId == 0) return;

    _setLoading(true);

    try {
      final routes =
          await ShipmentRouteApi.fetchRoutesByShipment(shipment.shipmentId);
      if (routes.isEmpty) {
        _setError("No routes found for this shipment.");
        return;
      }

      final lastRoute = routes.last;
      activeRoute = lastRoute;

      final vertices = lastRoute.decodedPolyline;
      if (vertices.isEmpty) return;

      await _addOriginMarker(vertices.first);
      await _addDestinationMarker(vertices.last);
      _drawRoutePolyline(vertices);

      // Zoom camera with vertical offset
      _zoomToRoute(vertices);

      _setError(null);
    } catch (e, st) {
      if (kDebugMode) print("❌ Failed to load shipment routes: $e\n$st");
      _setError("Failed to load shipment routes.");
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------
  // MARKERS
  // -----------------------------
  Future<void> _addOriginMarker(GeoCoordinates coords) async {
    if (_mapController == null || _originImage == null) return;

    _originMarker?.let(_mapController!.mapScene.removeMapMarker);
    _originMarker = MapMarker(coords, _originImage!)
      ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1);
    _mapController!.mapScene.addMapMarker(_originMarker!);
  }

  Future<void> _addDestinationMarker(GeoCoordinates coords) async {
    if (_mapController == null || _destinationImage == null) return;

    _destinationMarker?.let(_mapController!.mapScene.removeMapMarker);
    _destinationMarker = MapMarker(coords, _destinationImage!)
      ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1);
    _mapController!.mapScene.addMapMarker(_destinationMarker!);
  }

  // -----------------------------
  // POLYLINE
  // -----------------------------
  void _drawRoutePolyline(List<GeoCoordinates> vertices) {
    if (_mapController == null || vertices.isEmpty) return;

    _routePolyline?.let(_mapController!.mapScene.removeMapPolyline);

    final lineString = GeoPolyline(vertices);
    final width =
        MapMeasureDependentRenderSize.withSingleSize(RenderSizeUnit.pixels, 7);
    final representation = MapPolylineSolidRepresentation(
        width, const Color(0xFF007AFF), LineCap.round);

    _routePolyline = MapPolyline.withRepresentation(lineString, representation);
    _mapController!.mapScene.addMapPolyline(_routePolyline!);
  }

  Future<void> _animateFitRoute(GeoBox geoBox) async {
  if (_mapController == null) return;

  // Move camera anchor for bottom sheet
  _mapController!.camera.principalPoint =  Point2D(0.5, 0.30);

  // Step 1: Jump to area (no animation)
  _mapController!.camera.lookAtAreaWithGeoOrientation(
    geoBox,
    GeoOrientationUpdate(0, 0),
  );

  // Step 2: Subtle zoom-out animation (feels natural)
  await Future.delayed(const Duration(milliseconds: 80));

  _mapController!.camera.zoomBy(
  -0.5,
   Point2D(0.5, 0.30),
);
}


  // -----------------------------
  // ZOOM CAMERA TO ROUTE
  // -----------------------------
  void _zoomToRoute(List<GeoCoordinates> vertices) {
    if (_mapController == null || vertices.isEmpty) return;

    // 1️⃣ Compute raw bounding box
    double minLat = vertices.first.latitude;
    double maxLat = vertices.first.latitude;
    double minLng = vertices.first.longitude;
    double maxLng = vertices.first.longitude;

    for (final v in vertices) {
      minLat = v.latitude < minLat ? v.latitude : minLat;
      maxLat = v.latitude > maxLat ? v.latitude : maxLat;
      minLng = v.longitude < minLng ? v.longitude : minLng;
      maxLng = v.longitude > maxLng ? v.longitude : maxLng;
    }

    // 2️⃣ Padding factors (TUNE THESE)
    const double latPaddingFactor = 0.20; // 20% vertical reminder
    const double lngPaddingFactor = 0.15; // 15% horizontal reminder

    final latSpan = maxLat - minLat;
    final lngSpan = maxLng - minLng;

    // Handle very short routes
    final paddedLat = latSpan == 0 ? 0.005 : latSpan * latPaddingFactor;
    final paddedLng = lngSpan == 0 ? 0.005 : lngSpan * lngPaddingFactor;

    // 3️⃣ Expanded bounding box
    final paddedGeoBox = GeoBox(
      GeoCoordinates(
        minLat - paddedLat,
        minLng - paddedLng,
      ),
      GeoCoordinates(
        maxLat + paddedLat,
        maxLng + paddedLng,
      ),
    );

    // 4️⃣ Shift camera upward to avoid bottom sheet
    _mapController!.camera.principalPoint = Point2D(0.5, 0.30);

    // 5️⃣ Fit padded area (AUTO ZOOM)
    _mapController!.camera.lookAtAreaWithGeoOrientation(
      paddedGeoBox,
      GeoOrientationUpdate(0, 0),
    );
     _animateFitRoute(paddedGeoBox);
  }

  // -----------------------------
  // FOCUS ON CURRENT LOCATION
  // -----------------------------
  Future<void> focusOnCurrentLocation() async {
    if (_mapController == null) return;


    final coords = GeoCoordinates(
      activeRoute?.originLat ?? 0.0,
      activeRoute?.originLng ?? 0.0,
    );
    _configureCameraForBottomSheet();
    _mapController!.camera.lookAtPointWithGeoOrientationAndMeasure(
      coords,
      GeoOrientationUpdate(0, 50), // tilt 0°, heading 50°
      MapMeasure(MapMeasureKind.distanceInMeters, 1), //
    );
  }

  void _configureCameraForBottomSheet() {
    if (_mapController == null) return;

    _mapController!.camera.principalPoint = Point2D(0.5, 0.30);
  }

  // -----------------------------
  // LOADING / ERROR
  // -----------------------------
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  // -----------------------------
  // CLEAR MAP
  // -----------------------------
  void clear() {
    _routePolyline?.let((p) => _mapController?.mapScene.removeMapPolyline(p));
    _originMarker?.let((m) => _mapController?.mapScene.removeMapMarker(m));
    _destinationMarker?.let((m) => _mapController?.mapScene.removeMapMarker(m));
    _currentProviderPosition = null;

    _routePolyline = null;
    _originMarker = null;
    _destinationMarker = null;
    _currentRoute = null;

    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    clear();
    super.dispose();
  }
}

// -----------------------------
// Nullable extension
// -----------------------------
extension Nullable<T> on T? {
  void let(void Function(T it) fn) {
    final v = this;
    if (v != null) fn(v);
  }
}
