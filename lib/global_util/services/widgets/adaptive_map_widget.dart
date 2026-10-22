import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controler/google_map_controller_impl.dart';

/// Thin wrapper around GoogleMap for the Android-only build.
class AdaptiveMapWidget extends StatefulWidget {
  final GoogleMapControllerImpl? googleMapController;
  final Set<Marker> initialMarkers;
  final Set<Polyline> initialPolylines;
  final Set<Circle> initialCircles;
  final CameraPosition initialCameraPosition;
  final MapType mapType;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;

  final void Function(GoogleMapController)? onMapCreated;
  final void Function(LatLng)? onTap;
  final void Function(CameraPosition)? onCameraMove;
  final void Function()? onCameraIdle;

  const AdaptiveMapWidget({
    super.key,
    this.googleMapController,
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
  });

  @override
  State<AdaptiveMapWidget> createState() => _AdaptiveMapWidgetState();
}

class _AdaptiveMapWidgetState extends State<AdaptiveMapWidget> {
  GoogleMapControllerImpl? _googleController;

  @override
  void initState() {
    super.initState();
    _googleController = widget.googleMapController;
  }

  @override
  void didUpdateWidget(covariant AdaptiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _googleController = widget.googleMapController;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        _googleController?.onMapCreated(controller);
        widget.onMapCreated?.call(controller);
      },
      initialCameraPosition: widget.initialCameraPosition,
      mapType: widget.mapType,
      myLocationEnabled: widget.myLocationEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      markers: widget.initialMarkers,
      polylines: widget.initialPolylines,
      circles: widget.initialCircles,
      onTap: widget.onTap,
      onCameraMove: widget.onCameraMove != null
          ? (pos) => widget.onCameraMove!(pos)
          : null,
      onCameraIdle: widget.onCameraIdle,
    );
  }
}