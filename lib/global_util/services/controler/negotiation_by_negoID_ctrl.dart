import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/fetch_bookings_by_nego_id_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';

class NegotiationByIdController extends ChangeNotifier {
  NegotiationModel? negotiation;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch a negotiation by its ID and update UI state accordingly.
  Future<void> fetchNegotiationById(int negotiationId) async {
    _setLoading(true);

    try {
      final result = await NegotiationByIdApi.fetchNegotiationById(negotiationId);

      negotiation = result;
      errorMessage = null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ Error fetching negotiation by ID: $e");
        print(stackTrace);
      }
      errorMessage = "Failed to load negotiation details. Please try again later.";
    } finally {
      _setLoading(false);
    }
  }

  /// Helper to safely toggle loading and notify listeners.
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Refreshes the negotiation details (useful for pull-to-refresh).
  Future<void> refresh(int negotiationId) async {
    await fetchNegotiationById(negotiationId);
  }

  /// Clears current negotiation data.
  void clear() {
    negotiation = null;
    errorMessage = null;
    notifyListeners();
  }
}
