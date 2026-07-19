enum RoundLocalStatus { confirmed, sending, failed }

class NegotiationRound {
  final int? id;
  final int? negotiationId;
  final String? senderType; // "client" or "provider"
  final double? offeredPrice;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Client-only fields — never sent to or parsed from the API.
  final String? localId;
  final RoundLocalStatus localStatus;

  NegotiationRound({
    this.id,
    this.negotiationId,
    this.senderType,
    this.offeredPrice,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.localId,
    this.localStatus = RoundLocalStatus.confirmed,
  });

  factory NegotiationRound.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) return double.tryParse(value);
      return null;
    }

    return NegotiationRound(
      id: json['id'] as int?,
      negotiationId: json['negotiation'] as int?,
      senderType: json['sender_type']?.toString(),
      offeredPrice: parseDouble(json['offered_price']),
      message: json['message']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      // localId/localStatus intentionally omitted — server data is
      // always "confirmed" by definition.
    );
  }

  NegotiationRound copyWith({
    int? id,
    int? negotiationId,
    String? senderType,
    double? offeredPrice,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? localId,
    RoundLocalStatus? localStatus,
  }) {
    return NegotiationRound(
      id: id ?? this.id,
      negotiationId: negotiationId ?? this.negotiationId,
      senderType: senderType ?? this.senderType,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localId: localId ?? this.localId,
      localStatus: localStatus ?? this.localStatus,
    );
  }

  bool get isPending => localStatus == RoundLocalStatus.sending;
  bool get isFailed => localStatus == RoundLocalStatus.failed;
}