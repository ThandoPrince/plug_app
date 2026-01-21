import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_pictures_model.dart';
import 'package:flutter_application_1/global_util/services/models/provider_for_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';

class OrderServiceModel {
  final String? title;
  final ServiceModel? serviceRequired;
  final int? serviceId;
  final int? orderId;
  final double? basePrice;
  final double? finalPrice;
  final bool? isNegotiated;
  final String? client;
  final String? description;
  final int? providerForServiceId;
  final ProviderServiceModel? providerForService;
  final List<ServicePictureModel>? servicePictures;
  final double? proposalPrice;
  final DateTime? requestedDateTime;
  final DateTime? requestedDate;
  final String? notes;
  final ClientAddressModel? deliveryAddress;
  final DateTime? dateAndTimeCreated;
  final String? status;
  final bool? isBroadcasted;
  final List<String>? invitedProviders;
  final double? totalPrice;

  OrderServiceModel({
    this.title,
    this.servicePictures,
    this.serviceRequired,
    this.serviceId,
    this.orderId,
    this.basePrice,
    this.finalPrice,
    this.proposalPrice,
    this.providerForServiceId,
    this.isNegotiated,
    this.client,
    this.description,
    this.providerForService,
    this.requestedDateTime,
    this.requestedDate,
    this.notes,
    this.deliveryAddress,
    this.dateAndTimeCreated,
    this.status,
    this.isBroadcasted,
    this.invitedProviders,
    this.totalPrice,
  });

  // --------------------------------------------------
  // ✅ RESOLVERS (FIX YOUR UI ISSUES)
  // --------------------------------------------------

  /// Safe title resolution
  String get resolvedTitle {
    return title ??
        serviceRequired?.serviceName ??
        providerForService?.service.serviceName ??
        'Service';
  }

  /// Safe service name resolution
  String get resolvedServiceName {
    return serviceRequired?.serviceName ??
        providerForService?.service.serviceName ??
        'Unknown service';
  }

  /// Safe service ID resolution
  int? get resolvedServiceId {
    return serviceRequired?.serviceId ??
        providerForService?.service.serviceId ??
        serviceId;
  }

  // --------------------------------------------------
  // ✅ FROM JSON
  // --------------------------------------------------

  factory OrderServiceModel.fromJson(Map<String, dynamic> json) {
    /// Requested date
    final DateTime? requestedDate = json['requested_date'] != null
        ? DateTime.tryParse(json['requested_date'])
        : null;

    /// Requested time
    DateTime? requestedDateTime;
    if (json['requested_date_time'] != null && requestedDate != null) {
      final time = json['requested_date_time'].toString().split(':');
      if (time.length >= 2) {
        requestedDateTime = DateTime(
          requestedDate.year,
          requestedDate.month,
          requestedDate.day,
          int.tryParse(time[0]) ?? 0,
          int.tryParse(time[1]) ?? 0,
          time.length > 2 ? int.tryParse(time[2]) ?? 0 : 0,
        );
      }
    }

    /// Provider for service (ID or nested object)
    ProviderServiceModel? providerServiceModel;
    int? providerServiceId;

    final pfs = json['provider_for_service'];
    if (pfs is int) {
      providerServiceId = pfs;
    } else if (pfs is Map<String, dynamic>) {
      providerServiceId = pfs['id'] as int?;
      providerServiceModel = ProviderServiceModel.fromJson(pfs);
    }

    /// Service required (ID or object)
    ServiceModel? serviceRequired;
    int? serviceId;

    final sr = json['service_required'];
    if (sr is int) {
      serviceId = sr;
    } else if (sr is Map<String, dynamic>) {
      serviceId = sr['service_id'];
      serviceRequired = ServiceModel.fromJson(sr);
    }

    return OrderServiceModel(
      orderId: json['order_id'],
      title: json['title'],
      serviceRequired: serviceRequired,
      serviceId: serviceId,
      basePrice: double.tryParse(json['base_price']?.toString() ?? ''),
      finalPrice: double.tryParse(json['final_price']?.toString() ?? ''),
      proposalPrice: double.tryParse(json['proposal_price']?.toString() ?? ''),
      isNegotiated: json['is_negotiated'],
      client: json['client']?['client_profile']?['email_address'],
      description: json['description'],
      providerForServiceId: providerServiceId,
      providerForService: providerServiceModel,
      requestedDate: requestedDate,
      requestedDateTime: requestedDateTime,
      notes: json['notes'],
      deliveryAddress: json['delivery_address'] != null
          ? ClientAddressModel.fromJson(json['delivery_address'])
          : null,
      dateAndTimeCreated: json['date_and_time_created'] != null
          ? DateTime.tryParse(json['date_and_time_created'])
          : null,
      status: json['status'],
      isBroadcasted: json['is_broadcasted'],
      invitedProviders: (json['invited_providers'] as List?)
          ?.map((p) =>
              p['provider']?['sp_profile']?['email_address']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      totalPrice: double.tryParse(json['total_price']?.toString() ?? ''),
      servicePictures: (json['service_pictures'] as List?)
          ?.map((e) => ServicePictureModel.fromJson(e))
          .toList(),
    );
  }

  // --------------------------------------------------
  // ✅ TO JSON
  // --------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'service_required': serviceRequired?.toJson() ?? serviceId,
      'order_id': orderId,
      'base_price': basePrice,
      'proposal_price': proposalPrice,
      'final_price': finalPrice,
      'is_negotiated': isNegotiated,
      'client': client,
      'description': description,
      'provider_for_service': providerForServiceId,
      'requested_date': requestedDate?.toIso8601String(),
      'requested_date_time': requestedDateTime != null
          ? "${requestedDateTime!.hour.toString().padLeft(2, '0')}:${requestedDateTime!.minute.toString().padLeft(2, '0')}:${requestedDateTime!.second.toString().padLeft(2, '0')}"
          : null,
      'notes': notes,
      'delivery_address': deliveryAddress?.id,
      'date_and_time_created': dateAndTimeCreated?.toIso8601String(),
      'status': status,
      'is_broadcasted': isBroadcasted,
      'invited_providers': invitedProviders,
      'total_price': totalPrice,
    };
  }
}
