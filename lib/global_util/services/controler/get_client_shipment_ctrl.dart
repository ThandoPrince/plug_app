import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/client_shipment_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';



class ShipmentController extends ChangeNotifier {
  final List<Shipment> _shipments = [];
  bool _isLoading = false;
  String? _error;

  List<Shipment> get shipments => _shipments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch shipments for client
  Future<void> fetchShipmentsByClientEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ShipmentApi.getShipmentsByClientEmail(email);

      _shipments
        ..clear()
        ..addAll(data);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ ShipmentController error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _shipments.clear();
    _error = null;
    notifyListeners();
  }
}
