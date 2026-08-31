import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controler/device_capability_controller.dart';
import '../controler/google_map_controller_impl.dart';
import '../controler/fallback_map_controller_impl.dart';
import '../controler/map_controller_interface.dart';
import 'fallback_map_widget.dart';

/// Adaptive map widget that automatically chooses between Google Maps and fallback
/// based on device capabilities (GMS vs HMS)
class AdaptiveMapWidget extends StatefulWidget {
  final MapControllerInterface? googleMapController;
  final FallbackMapControllerImpl? fallbackMapController;
  final Set<Marker> initialMarkers;
  final Set<Polyline> initialPolylines;
  final Set<Circle> initialCircles;
  final CameraPosition initialCameraPosition;
  final MapType mapType;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;

  /// Called when the underlying GoogleMap has been created.
  /// Only fires on the Google Maps path — not on the fallback (static map) path.
  final void Function(GoogleMapController)? onMapCreated;

  final void Function(LatLng)? onTap;
  final void Function(CameraPosition)? onCameraMove;
  final void Function()? onCameraIdle;
  final String? googleMapsApiKey;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const AdaptiveMapWidget({
    super.key,
    this.googleMapController,
    this.fallbackMapController,
    this.initialMarkers = const {},
    this.initialPolylines = const {},
    this.initialCircles = const {},
    required this.initialCameraPosition,
    this.mapType = MapType.normal,
    this.myLocationEnabled = false,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
    this.onMapCreated,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
    this.googleMapsApiKey,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<AdaptiveMapWidget> createState() => _AdaptiveMapWidgetState();
}

class _AdaptiveMapWidgetState extends State<AdaptiveMapWidget> {
  DeviceCapabilityController? _deviceController;
  MapServiceType? _mapServiceType;
  bool _isChecking = true;
  GoogleMapControllerImpl? _googleController;
  FallbackMapControllerImpl? _fallbackController;
  bool _ownsFallbackController = false;

  @override
  void initState() {
    super.initState();
    _deviceController = DeviceCapabilityController.instance;
    _initializeControllers();
    _checkDeviceCapabilities();
  }

  @override
  void didUpdateWidget(covariant AdaptiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep the fallback controller (used for the static-map path) in sync
    // whenever the caller passes new markers/polylines/circles. The Google
    // path doesn't need this — it renders widget.initialMarkers/etc. live,
    // straight off the widget, on every build.
    final markersChanged = !_setEquals(oldWidget.initialMarkers, widget.initialMarkers);
    final polylinesChanged =
        !_setEquals(oldWidget.initialPolylines, widget.initialPolylines);
    final circlesChanged = !_setEquals(oldWidget.initialCircles, widget.initialCircles);

    if (markersChanged || polylinesChanged || circlesChanged) {
      _syncFallbackController();
    }

    // If the caller swaps in a different fallback controller instance,
    // drop our own if we'd created one.
    if (widget.fallbackMapController != oldWidget.fallbackMapController) {
      if (_ownsFallbackController) {
        _fallbackController?.dispose();
      }
      _fallbackController = widget.fallbackMapController ?? FallbackMapControllerImpl();
      _ownsFallbackController = widget.fallbackMapController == null;
      _syncFallbackController();
    }
  }

  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  void _initializeControllers() {
    _googleController = widget.googleMapController as GoogleMapControllerImpl?;
    _fallbackController = widget.fallbackMapController ?? FallbackMapControllerImpl();
    _ownsFallbackController = widget.fallbackMapController == null;

    _syncFallbackController();
  }

  /// Pushes the current initial markers/polylines/circles into the fallback
  /// controller. The Google path doesn't need this: GoogleMap is fed
  /// widget.initialMarkers/etc. directly on every build, so it's always live.
  void _syncFallbackController() {
    final fallback = _fallbackController;
    if (fallback == null) return;

    fallback.setMarkers(widget.initialMarkers);
    fallback.setPolylines(widget.initialPolylines);
    fallback.clearCircles();
    for (final circle in widget.initialCircles) {
      fallback.addCircle(circle);
    }
  }

  Future<void> _checkDeviceCapabilities() async {
    final type = await _deviceController!.checkMapServiceAvailability();
    if (mounted) {
      setState(() {
        _mapServiceType = type;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking || _mapServiceType == null) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    switch (_mapServiceType!) {
      case MapServiceType.google:
        return _buildGoogleMap();
      case MapServiceType.huawei:
        return _buildFallbackMap();
      case MapServiceType.unknown:
      default:
        return widget.errorWidget ??
            const Center(child: Text('Unable to determine map service'));
    }
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        _googleController?.onMapCreated(controller);
        // Forward to caller so app-level controllers (e.g. one that manages
        // markers via Provider) can attach and start driving the camera.
        widget.onMapCreated?.call(controller);
      },
      initialCameraPosition: CameraPosition(
        target: widget.initialCameraPosition.target,
        zoom: widget.initialCameraPosition.zoom,
        tilt: widget.initialCameraPosition.tilt,
        bearing: widget.initialCameraPosition.bearing,
      ),
      mapType: widget.mapType,
      myLocationEnabled: widget.myLocationEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      // Rendered live off the widget so any Provider/Consumer rebuild in the
      // caller (new markers, updated polylines, etc.) reaches the map
      // immediately — no separate controller to fall out of sync.
      markers: widget.initialMarkers,
      polylines: widget.initialPolylines,
      circles: widget.initialCircles,
      onTap: widget.onTap,
      onCameraMove: widget.onCameraMove != null
          ? (pos) => widget.onCameraMove!(CameraPosition(
                target: pos.target,
                zoom: pos.zoom,
                tilt: pos.tilt,
                bearing: pos.bearing,
              ))
          : null,
      onCameraIdle: widget.onCameraIdle,
    );
  }

  Widget _buildFallbackMap() {
    return FallbackMapWidget(
      controller: _fallbackController!,
      onTap: widget.onTap != null
          ? () {
              // For fallback, we can't get the exact lat/lng from tap
              // This would need a more sophisticated implementation
            }
          : null,
      loadingWidget: widget.loadingWidget,
      errorWidget: widget.errorWidget,
      staticMapApiKey: widget.googleMapsApiKey,
    );
  }

  @override
  void dispose() {
    if (_ownsFallbackController) {
      _fallbackController?.dispose();
    }
    super.dispose();
  }
}