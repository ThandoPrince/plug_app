import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';

class SessionModel {
  final int? sessionId;
  final Shipment? shipment;

  final DateTime? checkinTime;
  final Map<String, dynamic>? checkinLocation;

  final DateTime? checkoutTime;
  final Map<String, dynamic>? checkoutLocation;

  SessionModel({
    this.sessionId,
    this.shipment,
    this.checkinTime,
    this.checkinLocation,
    this.checkoutTime,
    this.checkoutLocation,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id'],
      shipment: json['shipment'] is Map
          ? Shipment.fromJson(json['shipment'])
          : null,
      checkinTime: json['checkin_time'] != null
          ? DateTime.parse(json['checkin_time'])
          : null,
      checkinLocation: json['checkin_location'],
      checkoutTime: json['checkout_time'] != null
          ? DateTime.parse(json['checkout_time'])
          : null,
      checkoutLocation: json['checkout_location'],
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
    };
  }

  bool get isCheckedOut => checkoutTime != null;
}
