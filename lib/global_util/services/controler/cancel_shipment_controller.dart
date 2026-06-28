import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/cancel_shipment_api.dart';


class ShipmentCancelController with ChangeNotifier {
  

  bool isLoading = false;
  String? errorMessage;
  bool success = false;

  Future<void> cancelShipment(int shipmentId) async {
    isLoading = true;
    errorMessage = null;
    success = false;
    notifyListeners();

    final result = await ShipmentCancelApi().cancelShipment(
      shipmentId: shipmentId,
    );

    if (result) {
      success = true;

      if (kDebugMode) {
        print("Shipment $shipmentId cancelled successfully");
      }
    } else {
      errorMessage = "Unable to cancel shipment. Please try again.";

      if (kDebugMode) {
        print("Failed to cancel shipment $shipmentId");
      }
    }

    isLoading = false;
    notifyListeners();
  }
}