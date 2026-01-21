import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'session_model.dart';

class SessionTokenModel {
  final int tokenId;
  final String checkinToken;
  final DateTime tokenExpiry;

  final SessionModel? session;
  final Shipment? shipment;

  final DateTime createdAt;

  const SessionTokenModel({
    required this.tokenId,
    required this.checkinToken,
    required this.tokenExpiry,
    this.session,
    this.shipment,
    required this.createdAt,
  });

  factory SessionTokenModel.fromJson(Map<String, dynamic> json) {
    return SessionTokenModel(
      tokenId: json['token_id'] as int,
      checkinToken: json['checkin_token'] as String,
      tokenExpiry: DateTime.parse(json['token_expiry']),
      session: json['session'] != null && json['session'] is Map
          ? SessionModel.fromJson(json['session'])
          : null,
      shipment: json['shipment'] != null && json['shipment'] is Map
          ? Shipment.fromJson(json['shipment'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_id': tokenId,
      'checkin_token': checkinToken,
      'token_expiry': tokenExpiry.toIso8601String(),
      'session': session?.toJson(),
      'shipment': shipment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Local helper – mirrors backend `is_valid()`
  bool get isExpired => DateTime.now().isAfter(tokenExpiry);

  bool get isValid => !isExpired;
}
