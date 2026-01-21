

class NegotiationRound {
  final int? id;
  final int? negotiationId;
  final String? senderType; // "client" or "provider"
  final double? offeredPrice;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NegotiationRound({
    this.id,
    this.negotiationId,
    this.senderType,
    this.offeredPrice,
    this.message,
    this.createdAt,
    this.updatedAt,
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
  );
}
}