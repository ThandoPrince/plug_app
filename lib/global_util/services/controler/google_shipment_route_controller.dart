import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/shipment_route_socket_service.dart';

import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_1/const/services/booking_services/shipment_route_api.dart';

class GoogleShipmentRouteController extends ChangeNotifier {
  final Shipment shipment;
  final ShipmentController shipmentController;
  

  String shipmentStatus;

  GoogleMapController? _mapController;

  GoogleShipmentRouteController({required this.shipment, required this.shipmentController,
})
      : shipmentStatus = shipment.shipmentStatus;

  final ShipmentRouteSocketService _socket = ShipmentRouteSocketService();

  bool _connected = false;
  bool get connected => _connected;

  bool _hasStarted = false;

  // -----------------------------
  // STATE
  // -----------------------------
  LatLng? _lastAnimatedPosition;
  ShipmentRouteModel? activeRoute;
  bool isLoading = false;
  String? errorMessage;

  // -----------------------------
  // FOLLOW MODE
  // -----------------------------
  bool _followProvider = true;
  bool get isFollowing => _followProvider;

  Timer? _followResumeTimer;
  static const _resumeDelay = Duration(seconds: 6);

  LatLng? _currentProviderPosition;

  // -----------------------------
  // MAP OBJECTS
  // -----------------------------
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

  // -----------------------------
  // INIT MAP
  // -----------------------------
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    loadShipmentRoutes();
  }

  // -----------------------------
  // LOAD INITIAL ROUTE (HTTP fallback once)
  // -----------------------------
  Future<void> loadShipmentRoutes() async {
    if (_mapController == null || shipment.shipmentId == 0) return;

    _setLoading(true);

    try {
      final routes =
          await ShipmentRouteApi.fetchRoutesByShipment(shipment.shipmentId);

      if (routes.isEmpty) {
        _setError("No route found");
        return;
      }

      activeRoute = routes.last;

      final points = activeRoute!.decodedPolyline
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      if (points.isEmpty) return;

      _drawRoute(points);
      _setMarkers(points);
      _fitRoute(points);

      _setError(null);
    } catch (e) {
      _setError("Failed to load route");
      if (kDebugMode) print(e);
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------
  // WEBSOCKET START
  // -----------------------------
  void startRealtime() {
    if (_hasStarted) return; // 🔥 prevents duplicate sockets
    _hasStarted = true;

    _socket.connect(
      shipmentId: shipment.shipmentId,
      onConnected: () {
        _connected = true;
        notifyListeners();
      },
      onDisconnected: () {
        _connected = false;
        notifyListeners();
      },
      onEvent: _handleSocketEvent,
    );
  }

  void disconnect() {
    _socket.disconnect();

    _connected = false;
    _hasStarted = false;

    _followResumeTimer?.cancel();
    notifyListeners();
  }

  // -----------------------------
  // SOCKET EVENTS
  // -----------------------------
  Future<void> _handleSocketEvent(Map<String, dynamic> event) async {
  if (kDebugMode) {
    print("Socket Event: $event");
  }

  

  switch (event["type"]) {
    case "route_updated":
      _updateRoute(event);
      break;

    case "shipment_status_update":
      shipmentStatus = event["status"] ?? shipmentStatus;
      if (shipmentStatus == "arrived") {
    shipmentController.fetchShipmentsByClientEmail(
      forceRefresh: true,
    );

    if (kDebugMode) {
        print("Shipment status updated -> $shipmentStatus");
      }
  }
 case "session_created":

  final shipmentId = event["shipment_id"];

  await shipmentController.onSessionCreated(
    shipmentId: shipmentId,
  );

  case "session_completed":
  disconnect(); 
  shipmentController.sessionCompleted(
    shipmentId: event["shipment_id"],
    sessionId: event["session_id"],
  );



      notifyListeners();
      break;

    case "error":
      errorMessage = event["message"] ?? "Route update failed";
      notifyListeners();
      break;
  }
}

  void _updateRoute(Map<String, dynamic> event) {
    try {
      final route = ShipmentRouteModel.fromJson(event["route"]);

      activeRoute = route;

      final points = route.decodedPolyline
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      _drawRoute(points);
      _setMarkers(points);

      if (_followProvider && points.isNotEmpty) {
        final last = points.last;

        if (_currentProviderPosition == null ||
            _hasMoved(_currentProviderPosition!, last)) {
          _follow(last);
        }
      }

      shipmentStatus =
          event["shipment_status"] ?? shipmentStatus;

      notifyListeners();
    } catch (_) {
      // 🔥 no stack trace leakage, no crash
    }
  }

  // -----------------------------
  // FOLLOW MODE
  // -----------------------------
  void onUserInteraction() {
    _followProvider = false;

    _followResumeTimer?.cancel();
    _followResumeTimer = Timer(_resumeDelay, () {
      _followProvider = true;

      if (_currentProviderPosition != null) {
        _follow(_currentProviderPosition!);
      }
    });
  }

  void recenter() {
    if (_currentProviderPosition == null) return;

    _followProvider = true;

    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentProviderPosition!,
          zoom: 16,
          tilt: 45,
        ),
      ),
    );
  }

  bool _hasMoved(LatLng a, LatLng b) {
    return (a.latitude - b.latitude).abs() > 0.00001 ||
        (a.longitude - b.longitude).abs() > 0.00001;
  }

  void _follow(LatLng pos) {
    _currentProviderPosition = pos;

    if (_mapController == null) return;

    final targetCamera = CameraPosition(
      target: pos,
      zoom: 16,
      tilt: 45,
      bearing: 0,
    );

    if (_lastAnimatedPosition != null) {
      final dx = (pos.latitude - _lastAnimatedPosition!.latitude).abs();
      final dy = (pos.longitude - _lastAnimatedPosition!.longitude).abs();

      if (dx < 0.00005 && dy < 0.00005) return;
    }

    _lastAnimatedPosition = pos;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(targetCamera),
    );
  }

  // -----------------------------
  // MARKERS
  // -----------------------------
  void _setMarkers(List<LatLng> points) {
    _markers.clear();

    final origin = points.first;
    final destination = points.last;

    _markers.add(
      Marker(
        markerId: const MarkerId("origin"),
        position: origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("destination"),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      ),
    );
  }

  // -----------------------------
  // POLYLINE
  // -----------------------------
  void _drawRoute(List<LatLng> points) {
    _polylines.clear();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: points,
        width: 5,
        color: const Color(0xFF007AFF),
      ),
    );
  }

  // -----------------------------
  // FIT CAMERA
  // -----------------------------
  void _fitRoute(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 120),
    );
  }

  // -----------------------------
  // HELPERS
  // -----------------------------
  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    errorMessage = e;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect(); // 🔥 IMPORTANT cleanup
    super.dispose();
  }
}