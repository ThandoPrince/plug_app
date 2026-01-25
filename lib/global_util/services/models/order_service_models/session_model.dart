import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';

class SessionModel {
  final int? sessionId;
  final Shipment? shipment;

  final DateTime? checkinTime;
  final Map<String, dynamic>? checkinLocation;

  final DateTime? checkoutTime;
  final Map<String, dynamic>? checkoutLocation;

  final String? sessionStatus;
  final DateTime? dateCreated;

  /// ⏱ Duration in seconds from backend
  final int durationSeconds;

  SessionModel({
    this.sessionId,
    this.shipment,
    this.checkinTime,
    this.checkinLocation,
    this.checkoutTime,
    this.checkoutLocation,
    this.sessionStatus,
    this.dateCreated,
    this.durationSeconds = 0,
  });

  factory SessionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SessionModel();

    return SessionModel(
      sessionId: json['session_id'] as int?,
      shipment: json['shipment'] is Map<String, dynamic>
          ? Shipment.fromJson(json['shipment'])
          : null,
      checkinTime: json['checkin_time'] != null
          ? DateTime.tryParse(json['checkin_time'])
          : null,
      checkinLocation: json['checkin_location'] as Map<String, dynamic>?,
      checkoutTime: json['checkout_time'] != null
          ? DateTime.tryParse(json['checkout_time'])
          : null,
      checkoutLocation: json['checkout_location'] as Map<String, dynamic>?,
      sessionStatus: json['session_status'] as String?,
      dateCreated: json['date_created'] != null
          ? DateTime.tryParse(json['date_created'])
          : null,

      /// 👈 THIS IS THE FIX
      durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'shipment': shipment,
      'checkin_time': checkinTime?.toIso8601String(),
      'checkin_location': checkinLocation,
      'checkout_time': checkoutTime?.toIso8601String(),
      'checkout_location': checkoutLocation,
      'session_status': sessionStatus,
      'date_created': dateCreated?.toIso8601String(),
      'duration': durationSeconds,
    };
  }

  // ---------------------------------------------------------------------------
  // 🧠 Computed helpers
  // ---------------------------------------------------------------------------

  /// Dart Duration object
  Duration get duration => Duration(seconds: durationSeconds);

  /// hh:mm:ss formatted
  String get formattedDuration {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  bool get isCheckedOut => checkoutTime != null;
  bool get isInProgress => sessionStatus == 'in_progress';
  bool get isCompleted => sessionStatus == 'completed';
}
