import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';


class ClientSessionLocationPingModel {
  final int? pingId;
  final SessionModel? session;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final bool? insideGeofence;
  final double? distanceFromSiteMeters;
  final DateTime? createdAt;

  const ClientSessionLocationPingModel({
    this.pingId,
    this.session,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.insideGeofence,
    this.distanceFromSiteMeters,
    this.createdAt,
  });

  /// JSON → Dart (defensive + fully nullable)
  factory ClientSessionLocationPingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ClientSessionLocationPingModel();

    return ClientSessionLocationPingModel(
      pingId: json['ping_id'] as int?,
      session: json['session'] is Map<String, dynamic>
          ? SessionModel.fromJson(json['session'] as Map<String, dynamic>)
          : null,
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      accuracy: json['accuracy'] is num ? (json['accuracy'] as num).toDouble() : null,
      insideGeofence: json['inside_geofence'] as bool?,
      distanceFromSiteMeters: json['distance_from_site_meters'] is num
          ? (json['distance_from_site_meters'] as num).toDouble()
          : null,
      createdAt: json['created_at'] is String ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
