import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/get_sp_rating_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/sp_rating_model.dart';


class SPRatingController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  List<SPRatingModel> _ratings = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SPRatingModel> get ratings => _ratings;

  Future<void> fetchRatings(
    int providerId,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _ratings =
          await SPRatingApi.fetchRatings(providerId);
           debugPrint("FETCH RATINGS CALLED: $providerId");
    } catch (e) {
      _error = e.toString();
      _ratings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _ratings = [];
    _error = null;
    notifyListeners();
  }
}