import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';

class ProviderServiceCostModel {
  final String providerEmail;
  final int serviceId;
  final CostOfServiceModel costOfService;

  ProviderServiceCostModel({
    required this.providerEmail,
    required this.serviceId,
    required this.costOfService,
  });

  factory ProviderServiceCostModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceCostModel(
      providerEmail: json['provider_email'] ?? '',
      serviceId: json['service_id'] ?? 0,
      costOfService: CostOfServiceModel.fromJson(
        json['cost_of_service'] as Map<String, dynamic>,
      ),
    );
  }
}