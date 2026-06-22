import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/client_completed_services_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';


class ClientRatingsController extends ChangeNotifier {
  final ClientCompletedServicesApi api = ClientCompletedServicesApi();
  List<RatingModel> _ratings = [];
  bool _isLoading = false;

 

  List<RatingModel> get ratings => _ratings;
  bool get isLoading => _isLoading;

  Future<void> fetchRatings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ratings = await ClientCompletedServicesApi.fetchRatingsByClientEmail();
    } catch (e) {
      debugPrint("Error fetching client ratings: $e");
      _ratings = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}