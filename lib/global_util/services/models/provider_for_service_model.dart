import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';

class ProviderServiceModel {
  final ServiceProviderModel provider;
  final ServiceModel service;

  ProviderServiceModel({
    required this.provider,
    required this.service,
  });

  // Create from JSON
  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      provider: json['provider'] is Map<String, dynamic>
          ? ServiceProviderModel.fromJson(json['provider'])
          : throw Exception('Invalid provider data'),
      service: json['service'] is Map<String, dynamic>
          ? ServiceModel.fromJson(json['service'])
          : throw Exception('Invalid service data'),
    );
  }

  // Convert to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      "provider": provider.spProfile.emailAddress, // use email as unique identifier
      "service": service.serviceId,
    };
  }

  @override
  String toString() => "${provider.fullName} - ${service.serviceName}";
}
