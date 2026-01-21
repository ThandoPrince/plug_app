import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/sp_profile_api.dart';
import 'package:flutter_application_1/global_util/services/models/sp_profile_model.dart';

class SpProfileController extends ChangeNotifier {
  List<SPProfileModel> _profiles = [];
  bool _isLoading = false;
  String? _error;

  List<SPProfileModel> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await SpProfileApi.fetchAllProfiles();

      _profiles = fetched;
      print('Fetched profiles count: ${_profiles.length}'); // Debug print
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
