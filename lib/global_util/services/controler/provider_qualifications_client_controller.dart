import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/provider_qualifications_client_api.dart';
import 'package:flutter_application_1/global_util/services/models/provider_qualification_model.dart';


class ProviderQualificationsClientController extends ChangeNotifier {
  List<ProviderQualificationModel> _qualifications = [];
  bool _isLoading = false;
  String? _error;

  List<ProviderQualificationModel> get qualifications => _qualifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQualifications(int providerId, int serviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _qualifications =
          await ProviderQualificationsClientApi.fetchQualifications(providerId, serviceId);
    } catch (e) {
      _error = _stripExceptionPrefix(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _stripExceptionPrefix(Object e) {
    final raw = e.toString();
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  void clear() {
    _qualifications = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}