import 'dart:convert';
import 'package:here_sdk/core.dart';

class ShipmentRouteModel {
  final int routeId;
  final int shipmentId;

  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;

  final int distanceMeters;
  final int durationSeconds;

  final Map<String, dynamic> geometry;

  final bool isActive;
  final bool recalculated;

  final DateTime createdAt;

  ShipmentRouteModel({
    required this.routeId,
    required this.shipmentId,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
    required this.isActive,
    required this.recalculated,
    required this.createdAt,
  });

  // ----------------------------
  // 🔹 Null-safe fromJson
  // ----------------------------
  factory ShipmentRouteModel.fromJson(Map<String, dynamic> json) {
    return ShipmentRouteModel(
      routeId: _parseInt(json['route_id']),
      shipmentId: _parseInt(json['shipment_id']),

      originLat: _parseDouble(json['origin_lat']),
      originLng: _parseDouble(json['origin_lng']),
      destinationLat: _parseDouble(json['destination_lat']),
      destinationLng: _parseDouble(json['destination_lng']),

      distanceMeters: _parseInt(json['distance_meters']),
      durationSeconds: _parseInt(json['duration_seconds']),

      geometry: _parseGeometry(json['geometry']),

      isActive: json['is_active'] ?? true,
      recalculated: json['recalculated'] ?? false,

      createdAt: _parseDateTime(json['created_at']),
    );
  }

  // ----------------------------
  // 🔹 To JSON
  // ----------------------------
  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'shipment_id': shipmentId,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'geometry': geometry,
      'is_active': isActive,
      'recalculated': recalculated,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ----------------------------
  // 🔹 Helpers
  // ----------------------------
  double get distanceKm => distanceMeters / 1000;
  int get durationMinutes => (durationSeconds / 60).round();

  ({double lat, double lng}) get origin => (lat: originLat, lng: originLng);
  ({double lat, double lng}) get destination => (lat: destinationLat, lng: destinationLng);

  /// Returns decoded polyline points if geometry is encoded
  List<GeoCoordinates> get decodedPolyline {
    // Backend vertices
    if (geometry.containsKey('vertices')) {
      final vertices = geometry['vertices'] as List? ?? [];
      return vertices
          .map((v) => GeoCoordinates(
                _parseDouble(v['lat']),
                _parseDouble(v['lng']),
              ))
          .toList();
    }

    // HERE polyline
    if (geometry.containsKey('polyline')) {
      final encoded = geometry['polyline'] as String? ?? '';
      final points = _decodePolyline(encoded);
      return points.map((p) => GeoCoordinates(p[0], p[1])).toList();
    }

    return [];
  }

  // ----------------------------
  // 🔹 Internal helpers
  // ----------------------------
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static Map<String, dynamic> _parseGeometry(dynamic geometry) {
    if (geometry == null) return {};
    if (geometry is String) {
      try {
        return jsonDecode(geometry) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
    if (geometry is Map) {
      return Map<String, dynamic>.from(geometry);
    }
    return {};
  }

  /// Polyline decoder (Google/HERE compatible)
  static List<List<double>> _decodePolyline(String encoded) {
    List<List<double>> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add([lat / 1E5, lng / 1E5]);
    }

    return points;
  }
}
