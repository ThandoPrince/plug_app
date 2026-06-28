import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/shipment_reshedule.api.dart';

class ShipmentRescheduleController with ChangeNotifier {
  bool isLoading = false;
  bool success = false;
  String? errorMessage;

  Future<bool> rescheduleShipment({
    required int shipmentId,
    required String newDate,
    required String newTime,
  }) async {
    isLoading = true;
    success = false;
    errorMessage = null;
    notifyListeners();

    final result = await ShipmentRescheduleApi().rescheduleShipment(
      shipmentId: shipmentId,
      newDate: newDate,
      newTime: newTime,
    );

    isLoading = false;

    if (result) {
      success = true;
      if (kDebugMode) {
        print("Shipment $shipmentId rescheduled successfully");
      }
    } else {
      success = false;
      errorMessage = "Unable to reschedule shipment. Please try again.";
      if (kDebugMode) {
        print("Failed to reschedule shipment $shipmentId");
      }
    }

    notifyListeners();
    return success; // 🔥 CRITICAL CHANGE
  }
}