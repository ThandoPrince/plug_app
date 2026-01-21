import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:intl/intl.dart';

class Shipment {
  final int shipmentId;
  final OrderServiceModel? serviceOrdered;

  final DateTime? shipmentScheduleDate;
  final String? shipmentScheduleTime;

  final String shipmentStatus;
  final bool shipmentConfirmation;
  final DateTime createdAt;

  Shipment({
    required this.shipmentId,
    required this.serviceOrdered,
    required this.shipmentScheduleDate,
    required this.shipmentScheduleTime,
    required this.shipmentStatus,
    required this.shipmentConfirmation,
    required this.createdAt,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      shipmentId: json['shipment_id'] ?? 0,

      serviceOrdered: json['service_ordered']?['order'] != null
    ? OrderServiceModel.fromJson(json['service_ordered']['order'])
    : null,

      shipmentScheduleDate: json['shipment_schedule_date'] != null
          ? DateTime.tryParse(json['shipment_schedule_date'])
          : null,

      shipmentScheduleTime: json['shipment_schedule_time'],

      shipmentStatus: json['shipment_status'] ?? '',

      shipmentConfirmation: json['shipment_confirmation'] ?? false,

      createdAt: DateTime.tryParse(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
  String get formattedDate {
  if (shipmentScheduleDate == null) return 'Unknown date';
  return DateFormat('EEE, dd MMM yyyy').format(shipmentScheduleDate!);
}

String get formattedTime {
  if (shipmentScheduleTime == null) return 'Unknown time';
  return shipmentScheduleTime!.substring(0, 5);
}

  static List<Shipment> listFromJson(List<dynamic> data) {
    return data.map((e) => Shipment.fromJson(e)).toList();
  }
}
