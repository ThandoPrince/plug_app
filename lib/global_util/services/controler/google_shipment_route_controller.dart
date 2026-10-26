import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/shipment_route_socket_service.dart';
import 'package:flutter_application_1/global_util/services/controler/client_order_realtime_controller.dart';

import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_location_ping_model.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_1/const/services/booking_services/shipment_route_api.dart';

// ============================================================
// Geo helpers
// ============================================================
//
// The old `_hasMoved` check compared raw lat/lng deltas against a flat
// 0.00001 threshold. That's not a fixed distance — 1 degree of longitude
// shrinks with cos(latitude), so the same threshold represents a
// different real-world distance depending on direction of travel and
// where on the globe you are. That's why "hasn't moved enough" could
// fire even when the provider clearly moved: the raw delta looked small
// even though the true distance covered a few meters.
//
// Below we work in meters (haversine) instead, which is direction- and
// latitude-independent, and gives us the real distance we need to filter
// GPS jitter out of the animation.
//
// Note: this build intentionally does NOT compute or use bearing. The
// provider marker always faces up and the camera never rotates — see
// the FOLLOW MODE / MARKERS sections below.

double _haversineMeters(LatLng a, LatLng b) {
  const earthRadius = 6371000.0;
  final lat1 = a.latitude * pi / 180;
  final lat2 = b.latitude * pi / 180;
  final dLat = (b.latitude - a.latitude) * pi / 180;
  final dLng = (b.longitude - a.longitude) * pi / 180;

  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(h), sqrt(1 - h));

  return earthRadius * c;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;



// ============================================================
// Smooth position animator
// ============================================================
//
// The provider's real position only arrives every few seconds over the
// socket. Snapping the marker/camera straight to each new fix looks
// jerky. Instead we interpolate visually between the last known point
// and the new one over roughly the same interval the updates are
// arriving at, so movement reads as continuous — the same trick used
// by ride-hailing style live-tracking maps.
class _SmoothPositionAnimator {
  _SmoothPositionAnimator({
    required this.onTick,
    this.tickRate = const Duration(milliseconds: 33), // ~30fps
    this.minMovementMeters = 1.5,
    this.minDuration = const Duration(milliseconds: 350),
    this.maxDuration = const Duration(milliseconds: 3000),
    this.defaultDuration = const Duration(milliseconds: 900),
    this.maxStaleDuration = const Duration(seconds: 6),
  });

  final void Function(LatLng position) onTick;
  final Duration tickRate;
  final double minMovementMeters;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration defaultDuration;

  /// Safety valve for the jitter filter below. A hard "ignore anything
  /// under minMovementMeters" rule is fine for a provider that's fully
  /// stationary, but a provider genuinely creeping forward — crawling
  /// traffic, someone walking slowly, a delivery navigating on foot inside
  /// a building — can send several fixes in a row that are each
  /// individually under the threshold even though real, continuous
  /// movement is happening. Without this, the dot sits frozen through all
  /// of those fixes and then suddenly jumps once the cumulative drift
  /// finally clears 1.5m — which reads as broken tracking, not as
  /// "filtering noise".
  ///
  /// Once this long has passed since the marker last actually moved, the
  /// next fix is accepted unconditionally, however small. That bounds the
  /// worst-case "frozen" duration to maxStaleDuration regardless of how
  /// slowly the provider is moving.
  final Duration maxStaleDuration;

  Timer? _timer;
  LatLng? _from;
  LatLng? _to;
  DateTime? _startTime;
  Duration _duration = const Duration(milliseconds: 900);

  /// Timestamp of the last raw fix received (accepted or filtered) — used
  /// only to estimate the socket's update cadence so the animation
  /// duration matches it.
  DateTime? _lastFixTime;

  /// Timestamp of the last fix that actually moved the marker. Distinct
  /// from `_lastFixTime` — the staleness check above is measured against
  /// this, not against every raw fix.
  DateTime? _lastAcceptedTime;

  bool get isAnimating => _timer != null;

  /// Feed a new raw fix. [currentVisualPosition] should be wherever the
  /// marker is *actually displayed right now* (not the last raw fix), so
  /// a fix arriving mid-animation blends onward smoothly instead of
  /// snapping back before animating again.
  void animateTo(
    LatLng target, {
    required LatLng currentVisualPosition,
  }) {
    final now = DateTime.now();
    final distance = _haversineMeters(currentVisualPosition, target);

    // Anchor the staleness clock the very first time we're called, so a
    // run of small movements starting before any acceptance still has
    // something to be measured against.
    _lastAcceptedTime ??= now;

    final timeSinceLastMove = now.difference(_lastAcceptedTime!);
    final isStale = timeSinceLastMove >= maxStaleDuration;

    // Filter GPS jitter: real driving/walking movement will clear this
    // easily on its own; a stationary provider's noisy fixes won't. But
    // never let this filter withhold movement indefinitely — see
    // maxStaleDuration above.
    if (distance < minMovementMeters && !isStale) {
      _lastFixTime = now;
      return;
    }

    // Animate over roughly the same interval fixes are arriving at, so
    // the motion neither stalls waiting for the next update nor rushes
    // ahead of it. Falls back to a sensible default for the first fix.
    final Duration interval = _lastFixTime == null
        ? defaultDuration
        : now.difference(_lastFixTime!);
    _lastFixTime = now;
    _lastAcceptedTime = now;

    _duration = Duration(
      milliseconds: interval.inMilliseconds.clamp(
        minDuration.inMilliseconds,
        maxDuration.inMilliseconds,
      ),
    );

    _from = currentVisualPosition;
    _to = target;
    _startTime = now;

    _timer?.cancel();
    _timer = Timer.periodic(tickRate, _tick);
  }

  void _tick(Timer timer) {
    final from = _from;
    final to = _to;
    final startTime = _startTime;
    if (from == null || to == null || startTime == null) {
      timer.cancel();
      return;
    }

    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
    final t = (elapsedMs / _duration.inMilliseconds).clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(t);

    final position = LatLng(
      _lerp(from.latitude, to.latitude, eased),
      _lerp(from.longitude, to.longitude, eased),
    );

    onTick(position);

    if (t >= 1.0) {
      timer.cancel();
      _timer = null;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class GoogleShipmentRouteController extends ChangeNotifier {
  final Shipment shipment;
  final ShipmentController shipmentController;
  final ClientOrderRealtimeController? realtime;

  bool isInsideGeofence = true;
  double? distanceFromSiteMeters;
  LatLng? geofenceProviderLocation;
  String shipmentStatus;
  ClientSessionLocationPingModel? latestPing;
  GoogleMapController? _mapController;

  GoogleShipmentRouteController({
    required this.shipment,
    this.realtime,
    required this.shipmentController,
  }) : shipmentStatus = shipment.shipmentStatus;

  final ShipmentRouteSocketService _socket = ShipmentRouteSocketService();



  bool _connected = false;
  bool get connected => _connected;
  bool _disposed = false;
  bool _hasStarted = false;
  BitmapDescriptor? _providerMarkerIcon;
  BitmapDescriptor? _clientMarkerIcon;

  // -----------------------------
  // STATE
  // -----------------------------
  ShipmentRouteModel? activeRoute;
  bool isLoading = false;
  String? errorMessage;

  /// True once we've successfully loaded (or received via socket) at
  /// least one route. This — not `isLoading`/`errorMessage` — is the
  /// signal the UI should use to decide whether it has "real" content to
  /// show. Both of those flags are transient and can flip for reasons
  /// unrelated to whether the currently-displayed data is still valid
  /// (a background refetch, a reconnect, a duplicate socket event), so
  /// gating full-screen loading/error states on them alone caused the UI
  /// to flicker back to a blocking screen even after content had already
  /// loaded successfully once.
  bool get hasRoute => activeRoute != null;

  /// Fingerprint of the last route broadcast we actually processed, used
  /// to cheaply drop exact-duplicate broadcasts (see _handleRoutePayload).
  String? _lastRoutePayloadFingerprint;

  // -----------------------------
  // ROUTE PROGRESS (trim polyline behind the provider)
  // -----------------------------
  //
  // The polyline drawn on the map is always just the *remaining* part of
  // the route ahead of the provider — the traveled portion behind them is
  // dropped rather than left cluttering the map. This needs its own state
  // because "how far along the route is the provider" isn't the same
  // question as "where is the provider" (see _updateTrimmedPolyline).
  List<LatLng> _routeGeometry = [];
  int _lastProjectedIndex = 0;
  Object? _currentRouteId;

  // -----------------------------
  // FOLLOW MODE
  // -----------------------------
  //
  // MrD-style tracking: the camera always follows the provider. There is
  // no "user pans away and follow disengages" state — a tap or drag on
  // the map never detaches the camera. `isFollowing` is kept as a
  // constant `true` so existing UI that reads it (e.g. to decide whether
  // to show a "recenter" button) keeps working without changes.
  bool get isFollowing => true;

  // -----------------------------
  // PROVIDER TRACKING / ANIMATION
  // -----------------------------
  late final _SmoothPositionAnimator _providerAnimator =
      _SmoothPositionAnimator(onTick: _onProviderTick);

  /// Where the provider marker is actually drawn right now (mid-animation
  /// included) — distinct from the last raw fix received from the socket.
  LatLng? _visualProviderPosition;

  LatLng? get currentProviderPosition => _visualProviderPosition;

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
  bool _routeLoaded = false;
bool _hasFocusedInitially = false;
  bool _isInitializing = true;
bool get isInitializing => _isInitializing;

void _markInitialized() {
  if (_isInitializing) {
    _isInitializing = false;
    notifyListeners();
  }
}

  void setMapController(GoogleMapController controller) {
    _mapController = controller;

    // Kick this off unconditionally and as early as possible — not just
    // on the HTTP-fetch success path in `loadShipmentRoutes()`. If the
    // screen opens before the provider has a route yet (empty fetch,
    // which is a normal state — see `hasRoute`), the icons need to
    // already be loaded by the time a *socket* event later delivers the
    // first real route, since `_handleRoutePayload` builds markers
    // directly and previously had no path to these icons at all in that
    // case, silently falling back to `BitmapDescriptor.defaultMarker`.
    // `_loadMarkerIcons` is safe to call more than once (`??=` inside).
    unawaited(_loadMarkerIcons());

    if (_routeLoaded) return;

    _routeLoaded = true;
    loadShipmentRoutes();
  }

  Future<void> _focusInitialCameraIfNeeded(LatLng position) async {
  if (_hasFocusedInitially || _disposed) return;
  _hasFocusedInitially = true;

  await Future.delayed(const Duration(milliseconds:400 ));
  if (_disposed) return;

  await _flyTo(position);
}

void applyStatusUpdate(Map data) {
  _updateShipmentStatus(data['status'] ?? data['shipment_status']);
}

  // -----------------------------
  // ELAPSED TIME
  // -----------------------------
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  String get elapsedTimeFormatted => _formatDuration(_elapsed);

  void startElapsedTimer(DateTime startTime) {
    _elapsedTimer?.cancel();

    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _elapsed = DateTime.now().difference(startTime);
        notifyListeners();
      },
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');

    return "$h:$m:$s";
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
      if (_disposed) return;

      if (routes.isEmpty) {
        // NOT an error: the provider simply hasn't started a route yet
        // (or the backend hasn't created one). Leave `activeRoute` null
        // and `errorMessage` null so the UI renders the real content
        // with an empty map — a later `route_updated` /
        // `shipment_route_updated` socket event will populate things
        // once the provider actually starts moving. Previously this set
        // `errorMessage = "No route found"`, which incorrectly triggered
        // the full-screen "Unable to load tracking" state for what is
        // just a normal pending state.
        _setError(null);
        return;
      }

      activeRoute = routes.last;
      if (_disposed) return;

      final points = activeRoute!.decodedPolyline
          .map((p) => LatLng(p.lat, p.lng))
          .toList();
      if (_disposed) return;

      if (points.isEmpty) return;

      await _loadMarkerIcons();
      if (_disposed) return;

      final provider = points.first;
      final client = points.last;

      _routeGeometry = points;
      _lastProjectedIndex = 0;
      // _currentRouteId is intentionally left unset here — it gets
      // populated from the first socket payload's `route_id`, which is
      // what matters for deciding whether later broadcasts are "more of
      // the same route" (see _handleRoutePayload).

      // First fix: nothing to interpolate from yet, so seed the visual
      // state directly and draw both markers.
      _visualProviderPosition = provider;

      _setInitialMarkers(provider: provider, client: client);
      _updateTrimmedPolyline(provider);
      await _focusInitialCameraIfNeeded(provider);

      // One-shot animated fly-in feels right for the first load; the
      // continuous tracking below uses a different technique (see
      // _followCamera) tuned for repeated small updates instead.
      await _flyTo(provider);

      _setError(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("loadShipmentRoutes failed:");
        debugPrint("$e");
        debugPrintStack(stackTrace: stackTrace);
      }

      _setError(e.toString());
    } finally {
      _setLoading(false);
      _markInitialized();
    }
  }

  Future<void> _loadMarkerIcons() async {
    _providerMarkerIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(64, 64)),
      "assets/icons/sp_marker.png",
    );

    _clientMarkerIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(64, 64)),
      "assets/icons/default_marker.png",
    );
  }

  // -----------------------------
  // WEBSOCKET START
  // -----------------------------
  void startRealtime(int shipmentId) {
    if (_connected || _hasStarted) return;

    _hasStarted = true;

    _socket.connect(
      shipmentId: shipmentId,
      onConnected: () {
        _connected = true;
        notifyListeners();
      },
      onDisconnected: () {
        _connected = false;
        _hasStarted = false;
        notifyListeners();
      },
      onEvent: _handleSocketEvent,
    );
  }

  void disconnect() {
    _socket.disconnect();

    _connected = false;
    _hasStarted = false;

    _providerAnimator.dispose();
    notifyListeners();
  }

  void setInitialPing(ClientSessionLocationPingModel? ping) {
    latestPing = ping;

    isInsideGeofence = ping?.insideGeofence ?? true;
    distanceFromSiteMeters = ping?.distanceFromSiteMeters;

    geofenceProviderLocation =
        ping?.latitude != null && ping?.longitude != null
            ? LatLng(ping!.latitude!, ping.longitude!)
            : null;

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
        if (kDebugMode) {
          print("📍 ROUTE UPDATED DATA: ${event["data"]}");
        }
        await _handleRoutePayload(event["data"]);
        break;

      case "shipment_route_updated":
        await _handleRoutePayload(event["data"]);
        break;

      case 'shipment_status_update':
case 'shipment_status_updated':
  final data = event['data'];

  _updateShipmentStatus(
    data is Map
        ? data['status'] ??
            data['shipment_status'] ??
            event['status']
        : event['status'],
  );
  break;

      case "session_created":
        await shipmentController.onSessionCreated(
          shipmentId: event["shipment_id"],
        );
        break;

      case "session_completed":
        disconnect();

        shipmentController.sessionCompleted(
          shipmentId: event["shipment_id"],
          sessionId: event["session_id"],
        );

        notifyListeners();
        break;

      case "geofence_ping_updated":
        debugPrint("PING RECEIVED");
        debugPrint(event.toString());
        final data = event["data"];

        if (data is Map<String, dynamic>) {
          latestPing = ClientSessionLocationPingModel.fromJson(data);

          isInsideGeofence = latestPing?.insideGeofence ?? true;
          distanceFromSiteMeters = latestPing?.distanceFromSiteMeters;

          geofenceProviderLocation =
              latestPing?.latitude != null && latestPing?.longitude != null
                  ? LatLng(
                      latestPing!.latitude!,
                      latestPing!.longitude!,
                    )
                  : null;
          debugPrint("Updated provider location: $geofenceProviderLocation");

          notifyListeners();
        }

        break;
      case "error":
        errorMessage = event["message"] ?? "Route update failed";
        notifyListeners();
        break;
    }
  }

  void _updateShipmentStatus(dynamic value) {
  if (value == null || _disposed) return;

  final newStatus = value.toString().trim().toLowerCase();

  if (newStatus.isEmpty || shipmentStatus == newStatus) return;

  shipmentStatus = newStatus;

  if (kDebugMode) {
    debugPrint('Shipment status updated: $newStatus');
  }

  notifyListeners();

  if (newStatus == 'arrived') {
    shipmentController.fetchShipmentsByClientEmail(
      forceRefresh: true,
    );
  }
}

  Future<void> _handleRoutePayload(dynamic json) async {
    try {
      if (json is! Map) {
        if (kDebugMode) print("Route payload wasn't a JSON object, ignoring.");
        return;
      }

      // Cheap dedup guard: the backend can (and does, per the logs) send
      // the exact same route broadcast more than once in a row. Fully
      // reprocessing that — decoding a few hundred polyline points,
      // rebuilding the route model, redrawing markers/polyline, and
      // notifying listeners — for data that hasn't changed is pure waste,
      // and was almost certainly a contributor to the frame drops you
      // saw. Route id + the live fix is enough to fingerprint a broadcast.
      final originLat = _asDouble(json['origin_lat']);
      final originLng = _asDouble(json['origin_lng']);
      final fingerprint = "${json['route_id']}_${originLat}_$originLng";

      if (fingerprint == _lastRoutePayloadFingerprint) {
        return;
      }
      _lastRoutePayloadFingerprint = fingerprint;

      final route = ShipmentRouteModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      );
      activeRoute = route;
      

      final points =
          route.decodedPolyline.map((p) => LatLng(p.lat, p.lng)).toList();

      if (points.isEmpty) {
        if (kDebugMode) {
          print("Received empty route.");
        }
        return;
      }

      // Reset progress tracking only when this is genuinely a different
      // route (e.g. the backend recalculated a new path), not just a new
      // location broadcast for the same route — otherwise every update
      // would restart the nearest-point search from scratch and lose the
      // small monotonic-forward window that keeps the trim from jittering
      // backward on GPS noise (see _findNearestPointIndex).
      final routeId = json['route_id'];
      if (routeId != _currentRouteId) {
        _currentRouteId = routeId;
        _lastProjectedIndex = 0;
      }
      _routeGeometry = points;

      // IMPORTANT: the provider's live position is `origin_lat`/
      // `origin_lng` on the payload itself, NOT `points.first`.
      //
      // `points` comes from the route's road-snapped geometry, and that
      // geometry isn't necessarily regenerated on every single location
      // ping — recomputing a route is comparatively expensive, so the
      // backend can (and does) reuse geometry across a few broadcasts
      // while `origin_lat`/`origin_lng` keep updating underneath it. Using
      // `points.first` as "the provider" meant the marker/camera could sit
      // frozen for several real updates even though the provider had
      // genuinely moved, because the number we were checking distance
      // against wasn't the live fix at all.
      //
      // Same logic for the destination/client marker: prefer the explicit
      // destination_lat/destination_lng over the last polyline vertex.
      final destLat = _asDouble(json['destination_lat']);
      final destLng = _asDouble(json['destination_lng']);

      final providerFix = (originLat != null && originLng != null)
          ? LatLng(originLat, originLng)
          : points.first; // fallback if the backend ever omits these
      final client = (destLat != null && destLng != null)
          ? LatLng(destLat, destLng)
          : points.last;

      // Guarantees real icons even if this is the very first route this
      // controller has ever seen (e.g. status just flipped to
      // "in_transit" while the client was already sitting on this
      // screen with no route loaded yet — see setMapController). A
      // no-op if they're already loaded, since _loadMarkerIcons caches
      // via `??=`.
      await _loadMarkerIcons();
      if (_disposed) return;

      _updateClientMarker(client);

      // Route redraw is instant (the line itself), but the provider dot
      // eases toward the new fix rather than jumping — see
      // _SmoothPositionAnimator for why. The polyline trim runs both here
      // (so it's correct immediately, even if the movement is too small
      // to trigger an animation) and on every animation tick in
      // _onProviderTick (so it keeps shortening smoothly in sync with the
      // marker while an animation is in progress).
      _updateTrimmedPolyline(_visualProviderPosition ?? providerFix);
      _updateProviderPosition(providerFix);
      _updateTrimmedPolyline(_visualProviderPosition ?? providerFix);
_updateProviderPosition(providerFix);

const preTransit = {'pending', 'rescheduled', 'not_in_transit'};
if (preTransit.contains(shipmentStatus.trim().toLowerCase())) {
  _updateShipmentStatus('in_transit');
}

      if (kDebugMode) {
        print("========== ROUTE UPDATE ==========");
        print("Points       : ${points.length}");
        print(
          "Live fix     : ${providerFix.latitude}, ${providerFix.longitude}",
        );
        print("Visual pos   : $_visualProviderPosition");
        print("==================================");
      }

      notifyListeners();
    } catch (e, s) {
      if (kDebugMode) {
        print("Failed applying route update");
        print(e);
        print(s);
      }
    }
    finally {
    // A socket payload landing before loadShipmentRoutes() has even
    // fired (e.g. HTTP still in flight, or setMapController() hasn't
    // run yet) is itself proof we've resolved *something* real — no
    // need to wait for the HTTP path to also finish.
    _markInitialized();
  }
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // -----------------------------
  // PROVIDER TRACKING
  // -----------------------------

  void _updateProviderPosition(LatLng target) {
  final current = _visualProviderPosition ?? target;
  final isFirstFix = _visualProviderPosition == null;

  _providerAnimator.animateTo(target, currentVisualPosition: current);

  if (isFirstFix) {
    // No prior fix to animate from — place it immediately.
    _onProviderTick(target);
    unawaited(_focusInitialCameraIfNeeded(target));
  }
}

  /// Called on every animation frame (~30fps) while interpolating between
  /// the provider's last two known fixes, and once immediately for the
  /// very first fix.
  void _onProviderTick(LatLng position) {
    _visualProviderPosition = position;

    _updateProviderMarker(position);
    _updateTrimmedPolyline(position);

    // MrD-style tracking: the camera follows on every single frame of
    // provider movement, unconditionally. There is no follow flag to
    // check and nothing a map gesture can do to stop it.
    _followCamera(position);

    notifyListeners();
  }

  // -----------------------------
  // FOLLOW MODE
  // -----------------------------
  //
  // Intentionally a no-op. Wired up here (rather than deleted) so that
  // any existing `onCameraMoveStarted`/gesture callback in the view layer
  // that calls this can stay as-is — tapping or dragging the map simply
  // has no effect on tracking. The very next provider tick (as often as
  // ~30x/second) recenters the camera regardless.
  void onUserInteraction() {}

  /// Forces an immediate re-center in case the map ever visibly drifted
  /// (e.g. right after a `fitRoute` call). Not required for normal
  /// tracking, since `_followCamera` already runs on every frame.
  void recenter() {
    if (_visualProviderPosition == null) return;
    _flyTo(_visualProviderPosition!);
  }

  /// Continuous tracking camera update, called every animation tick.
  ///
  /// Deliberately uses `moveCamera` (an instant cut, no built-in
  /// animation) rather than `animateCamera`. We're already interpolating
  /// position ~30 times a second in `_SmoothPositionAnimator`, so stacking
  /// the SDK's own animated flight on top of that would fight our
  /// interpolation and look janky/rubber-banded. A rapid sequence of
  /// instant repositions, driven by our own eased interpolation, is what
  /// actually reads as one smooth continuous pan — this is the same
  /// technique used by live-tracking maps in ride-hailing apps.
  ///
  /// Bearing is always 0 (north-up): the marker never rotates, so
  /// rotating the camera instead would make it look like the marker was
  /// spinning relative to the screen, which is exactly what we don't want.
  void _followCamera(LatLng position) {
    if (_disposed) return;

    if (_mapController == null) {
      // If you're seeing "camera never moves", this is almost always why:
      // setMapController() was never called (e.g. GoogleMap's onMapCreated
      // isn't wired to it), so every tick bails out right here.
      debugPrint(
        "ShipmentRouteController: _followCamera called with no map "
        "controller attached — camera cannot move. "
        "Make sure GoogleMap's onMapCreated calls setMapController().",
      );
      return;
    }

    try {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17,
            tilt: 45,
            bearing: 0,
          ),
        ),
      );
    } on StateError {
      // Map already disposed.
    } catch (e, s) {
      // Logged unconditionally via debugPrint (works in release builds
      // too, unlike the old kDebugMode-gated print) — a swallowed
      // exception here previously looked identical to "camera doesn't
      // move at all", with zero signal outside debug mode.
      debugPrint("ShipmentRouteController: camera follow failed: $e");
      debugPrint("$s");
    }
  }

  /// One-shot animated camera flight, used for discrete moments (initial
  /// load, an explicit `recenter()` call) where a deliberate animated
  /// flourish reads as intentional rather than as part of continuous
  /// tracking.
  Future<void> _flyTo(LatLng position) async {
    if (_disposed || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17,
            tilt: 45,
            bearing: 0,
          ),
        ),
      );
    } on StateError catch (e) {
      if (kDebugMode) {
        print("Map already disposed:");
        print(e);
      }
    } catch (e, s) {
      if (kDebugMode) {
        print("Camera animation failed:");
        print(e);
        print(s);
      }
    }
  }

  // -----------------------------
  // MARKERS
  // -----------------------------

  /// Full marker rebuild — only used on initial load, since after that
  /// the client marker is static and the provider marker updates in
  /// place via `_updateProviderMarker` to avoid rebuilding the whole set
  /// on every animation tick.
  void _setInitialMarkers({required LatLng provider, required LatLng client}) {
    _markers
      ..clear()
      ..add(_buildProviderMarker(provider))
      ..add(_buildClientMarker(client));
  }

  void _updateProviderMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId == const MarkerId("provider"));
    _markers.add(_buildProviderMarker(position));
  }

  void _updateClientMarker(LatLng position) {
    _markers.removeWhere((m) => m.markerId == const MarkerId("client"));
    _markers.add(_buildClientMarker(position));
  }

  Marker _buildProviderMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId("provider"),
      position: position,
      icon: _providerMarkerIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
      // Rotation intentionally omitted (defaults to 0) and `flat` left
      // false: the provider marker always faces straight up on screen,
      // regardless of the provider's real heading. Combined with the
      // camera's fixed bearing of 0 in `_followCamera`/`_flyTo`, "up" on
      // screen always means "up" for the marker too.
    );
  }

  Marker _buildClientMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId("client"),
      position: position,
      icon: _clientMarkerIcon ?? BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
    );
  }

  

  // -----------------------------
  // POLYLINE (trimmed to what's ahead of the provider)
  // -----------------------------

  /// Rebuilds the route polyline so it only shows what's *ahead* of the
  /// provider — the traveled portion behind them is dropped rather than
  /// left cluttering the map, matching how live-tracking maps typically
  /// render progress along a route.
  void _updateTrimmedPolyline(LatLng providerPos) {
    if (_routeGeometry.isEmpty) return;

    final nearestIndex = _findNearestPointIndex(providerPos);
    _lastProjectedIndex = nearestIndex;

    // The remaining line starts at the provider's actual live position
    // (not the nearest route vertex) so there's no visible gap or overlap
    // between the marker and where the line picks up.
    final remaining = nearestIndex >= _routeGeometry.length - 1
        ? [providerPos, _routeGeometry.last]
        : [providerPos, ..._routeGeometry.sublist(nearestIndex + 1)];

    _polylines
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: remaining,
          width: 5,
          color: const Color(0xFF007AFF),
        ),
      );
  }

  /// Finds the index of the route vertex closest to [from].
  ///
  /// Searches forward from a small window behind the last match
  /// (`_lastProjectedIndex`) rather than the whole geometry every time.
  /// Two things fall out of that:
  ///  - It's cheap: a route with hundreds of vertices doesn't mean
  ///    hundreds of distance checks on every one of the ~30 animation
  ///    ticks per second.
  ///  - It's stable: real progress along a route is monotonic, so
  ///    anchoring the search near the last known position (with a small
  ///    backward allowance for GPS jitter) stops the trim point from
  ///    jumping to some coincidentally-nearby vertex elsewhere on the
  ///    route (e.g. where the path loops back near itself).
  int _findNearestPointIndex(LatLng from) {
    const backtrackWindow = 5;
    final start = (_lastProjectedIndex - backtrackWindow)
        .clamp(0, _routeGeometry.length - 1);

    var bestIndex = start;
    var bestDistance = _haversineMeters(from, _routeGeometry[start]);

    for (var i = start + 1; i < _routeGeometry.length; i++) {
      final d = _haversineMeters(from, _routeGeometry[i]);
      if (d < bestDistance) {
        bestDistance = d;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  // -----------------------------
  // FIT CAMERA (unused by default flow, kept for callers that want a
  // bounds-fit view instead of following the provider)
  // -----------------------------
  Future<void> fitRoute(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty || _disposed) return;

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

    if (_disposed || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 120),
      );
    } on StateError {
      // Map was disposed.
    }
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
    _disposed = true;
    _elapsedTimer?.cancel();
    disconnect();
    _providerAnimator.dispose();
    _mapController = null;

    super.dispose();
  }
}