import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/shipment_confirm_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ShipmentConfirmController with ChangeNotifier {
  // API instance initialized inside the controller
  final ShipmentConfirmApi api = ShipmentConfirmApi(
    baseUrl: dotenv.env['API_BASE_URL'] ?? '', // <-- replace with your API URL
  );

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get response => _response;

  /// Confirm a shipment by ID
  Future<void> confirmShipment(int shipmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await api.confirmShipment(shipmentId);

      // Handle "already confirmed" response
      if (result.containsKey("detail") &&
          result["detail"] == "Shipment already confirmed") {
        _response = result;
      } else {
        _response = result;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _response = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear state
  void clear() {
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
