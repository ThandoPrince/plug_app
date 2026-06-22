
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';
import 'package:flutter_application_1/global_util/services/models/provider_for_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

class NegotiationModel {
  final int? negotiationId;
  final int? serviceOrderId;
  final ProviderServiceModel? providerForNegotiation;
  final double? basePrice;
  final double? proposedPrice;
  final double? providerResponsePrice;
  final String? status;
  final String? lastResponder;
  final int? roundCount;
  final int? maxRounds;
  final DateTime? createdAt;
  final List<NegotiationRound>? rounds;

  NegotiationModel({
    this.negotiationId,
    this.serviceOrderId,
    this.providerForNegotiation,
    this.basePrice,
    this.proposedPrice,
    this.providerResponsePrice,
    this.status,
    this.lastResponder,
    this.roundCount,
    this.maxRounds,
    this.createdAt,
    this.rounds,
  });

  factory NegotiationModel.fromJson(Map<String, dynamic> json) {
  double? tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  return NegotiationModel(
    negotiationId: json['negotiation_id'] as int?,
    serviceOrderId: json['service_order'] as int?,
      providerForNegotiation:
    json['provider_for_negotiation'] != null
        ? ProviderServiceModel.fromJson(
            json['provider_for_negotiation'])
        : null,
    basePrice: tryParseDouble(json['base_price']),
    proposedPrice: tryParseDouble(json['proposed_price']),
    providerResponsePrice: tryParseDouble(json['provider_response_price']),
    status: json['status']?.toString(),
    lastResponder: json['last_responder']?.toString(),
    roundCount: json['round_count'] as int?,
    maxRounds: json['max_rounds'] as int?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    rounds: (json['rounds'] as List<dynamic>?)
        ?.map((e) => NegotiationRound.fromJson(e)) 
        .toList(),
  );
}
}