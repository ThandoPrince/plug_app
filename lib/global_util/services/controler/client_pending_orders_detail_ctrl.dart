import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/client_pending_order_detail_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';



class ClientPendingOrdersDetailCtrl extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  OrderServiceModel? booking;

  Future<void> fetchBookingByOrderID(int orderId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      booking = await ClientPendingOrderDetailApi.fetchBookingByOrderID(orderId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
