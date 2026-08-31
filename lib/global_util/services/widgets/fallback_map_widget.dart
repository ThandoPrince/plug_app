import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controler/fallback_map_controller_impl.dart';
import '../controler/map_controller_interface.dart';

/// Fallback map widget for devices without Google Maps
/// Shows a static map image with overlay markers and polylines
class FallbackMapWidget extends StatelessWidget {
  final FallbackMapControllerImpl controller;
  final VoidCallback? onTap;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? staticMapApiKey;
  final Map<String, String>? staticMapParameters;

  const FallbackMapWidget({
    super.key,
    required this.controller,
    this.onTap,
    this.loadingWidget,
    this.errorWidget,
    this.staticMapApiKey,
    this.staticMapParameters,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final center = controller.center;
        final zoom = controller.zoom;
        final markers = controller.markers;
        final polylines = controller.polylines;
        final circles = controller.circles;

        return Stack(
          children: [
            // Static map image
            _buildStaticMapImage(center, zoom, markers, polylines, circles),

            // Attribution / notice
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Map view limited on this device. Open in Google Maps app for full experience.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Tap handler
            if (onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build static map image using Google Static Maps API
  Widget _buildStaticMapImage(
    LatLng center,
    double zoom,
    List<MapMarker> markers,
    List<MapPolyline> polylines,
    List<MapCircle> circles,
  ) {
    // Build the static map URL
    final url = _buildStaticMapUrl(center, zoom, markers, polylines, circles);
    
  debugPrint('FallbackMapWidget: static map URL = $url');

    return Positioned.fill(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Map unavailable',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }

  /// Build the Google Static Maps API URL
  String _buildStaticMapUrl(
    LatLng center,
    double zoom,
    List<MapMarker> markers,
    List<MapPolyline> polylines,
    List<MapCircle> circles,
  ) {
    final buffer = StringBuffer('https://maps.googleapis.com/maps/api/staticmap?');

    // Center and zoom
    buffer.write('center=${center.latitude},${center.longitude}&');
    buffer.write('zoom=${zoom.round()}&');

    // Size (use a reasonable default, could be made configurable)
    buffer.write('size=600x400&');

    // Scale for high-DPI screens
    buffer.write('scale=2&');

    // Format
    buffer.write('format=png&');

    // Map type
    buffer.write('maptype=roadmap&');

    // Add markers
    for (final marker in markers) {
      buffer.write('markers=');
      buffer.write('color:red|');
      buffer.write('label:${_getMarkerLabel(marker)}|');
      buffer.write('${marker.position.latitude},${marker.position.longitude}&');
    }

    // Add polylines
    for (final polyline in polylines) {
      buffer.write('path=');
      buffer.write('color:${_colorToHex(polyline.color)}|');
      buffer.write('weight:${polyline.width.round()}|');
      buffer.write('geodesic:${polyline.geodesic ? "true" : "false"}|');
      final points = polyline.points
          .map((p) => '${p.latitude},${p.longitude}')
          .join('|');
      buffer.write('enc:${Uri.encodeComponent(points)}&');
    }

    // Add circles (approximate with path)
    for (final circle in circles) {
      buffer.write('path=');
      buffer.write('color:${_colorToHex(circle.strokeColor)}|');
      buffer.write('weight:${circle.strokeWidth.round()}|');
      buffer.write('fillcolor:${_colorToHex(circle.fillColor)}|');
      // Approximate circle with points
      final circlePoints = _generateCirclePoints(circle.center, circle.radius);
      final points = circlePoints
          .map((p) => '${p.latitude},${p.longitude}')
          .join('|');
      buffer.write('enc:${Uri.encodeComponent(points)}&');
    }

    // API key
    if (staticMapApiKey != null && staticMapApiKey!.isNotEmpty) {
      buffer.write('key=$staticMapApiKey&');
    }

    return buffer.toString();
  }

  String _getMarkerLabel(MapMarker marker) {
    // Use first letter of markerId or a number
    if (marker.markerId.isNotEmpty) {
      return marker.markerId[0].toUpperCase();
    }
    return 'A';
  }

  String _colorToHex(Color color) {
    return '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}'; // with alpha
  }

  List<LatLng> _generateCirclePoints(LatLng center, double radiusMeters) {
    const int points = 32;
    final List<LatLng> circlePoints = [];
    const double earthRadius = 6371000.0;

    for (int i = 0; i < points; i++) {
      final double angle = (2 * 3.14159 * i) / points;
      final double latOffset = (radiusMeters / earthRadius) * (180 / 3.14159) * cos(angle);
      final double lngOffset = (radiusMeters / earthRadius) * (180 / 3.14159) * sin(angle) / cos(center.latitude * 3.14159 / 180);
      circlePoints.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }
    return circlePoints;
  }
}