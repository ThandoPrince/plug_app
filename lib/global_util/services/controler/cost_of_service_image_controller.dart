import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/cost_of_service_image_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/cost_of_service_image.dart';

class CostOfServiceImageController extends ChangeNotifier {
  List<CostOfServiceImageModel> _images = [];
  bool _isLoading = false;
  String? _error;

  List<CostOfServiceImageModel> get images => _images;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchImagesByCostId(int? costId) async {
    if (costId == null) {
      _images = [];
      _error = 'Cost ID is required.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _images = [];
    notifyListeners();

    try {
      _images = await CostOfServiceImageApi.fetchImagesByCostId(costId);

      if (_images.isEmpty) {
        _error = 'No images found for this cost of service.';
      }
    } catch (e) {
      _error = e.toString();
      _images = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _images = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}