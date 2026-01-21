import 'package:flutter_application_1/global_util/services/models/service_groups.dart';

class ServiceModel {
  final int serviceId;
  final String serviceName;
  final String? description;
  final int providerCount;
  final int activeProviderCount;
  final ServiceGroupModel? serviceGroup;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    this.description,
    this.providerCount = 0,
    this.activeProviderCount = 0,
    this.serviceGroup,
  });

  // --------------------------------------------------
  // ✅ UI SAFE GETTERS
  // --------------------------------------------------

  /// Always return something usable
  String get resolvedServiceName {
    return serviceName.isNotEmpty ? serviceName : 'Unknown service';
  }

  String get resolvedGroupName {
    return serviceGroup?.name ?? 'Other';
  }

  // --------------------------------------------------
  // ✅ FROM JSON (DEFENSIVE)
  // --------------------------------------------------

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['service_name']?.toString().trim();

    return ServiceModel(
      serviceId: json['service_id'] is int
          ? json['service_id']
          : int.tryParse(json['service_id']?.toString() ?? '') ?? 0,

      serviceName: (rawName != null && rawName.isNotEmpty)
          ? rawName
          : 'Unknown service',

      description: json['description']?.toString(),

      providerCount: json['provider_count'] is int
          ? json['provider_count']
          : int.tryParse(json['provider_count']?.toString() ?? '') ?? 0,

      activeProviderCount: json['active_provider_count'] is int
          ? json['active_provider_count']
          : int.tryParse(
                  json['active_provider_count']?.toString() ?? '') ??
              0,

      serviceGroup: json['service_group'] is Map<String, dynamic>
          ? ServiceGroupModel.fromJson(json['service_group'])
          : null,
    );
  }

  // --------------------------------------------------
  // ✅ TO JSON
  // --------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'description': description,
      'provider_count': providerCount,
      'active_provider_count': activeProviderCount,
      'service_group': serviceGroup?.toJson(),
    };
  }
}
