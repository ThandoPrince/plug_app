import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/client_shipment_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';

class ShipmentController extends ChangeNotifier {
  final List<Shipment> _shipments = [];
  bool _isLoading = false;
  String? _error;
  String? _clientEmail; // <- store once

  List<Shipment> get shipments => _shipments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchShipmentsByClientEmail() async {
  
    await _fetch();
  }

  Future<void> refresh() async {
    if (_clientEmail == null) return;
    await _fetch();
  }

  

  Future<void> _fetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await ShipmentApi.getShipmentsByClientEmail();

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
