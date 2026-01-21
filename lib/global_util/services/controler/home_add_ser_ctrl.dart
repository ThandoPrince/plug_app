// import 'package:flutter/foundation.dart';
// import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
// import 'package:flutter_application_1/global_util/services/models/sp_address_model.dart';
// import 'package:flutter_application_1/const/services/sp_add_by_service_api.dart';

// class SelectedServiceProvidersCtrl with ChangeNotifier {
//   List<ServiceProviderModel> _selectedProviders = [];
//   bool _isLoading = false;
//   String? _errorMessage;

//   List<ServiceProviderModel> get selectedProviders => _selectedProviders;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   /// Fetch selected SPs for a given service ID and map to ServiceProviderModel
//   Future<void> fetchSelectedProviders(int serviceId) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final spAddresses = await SpAddByServiceApi.fetchAddressByService(serviceId);
//       final addresssp = await SpAddByServiceApi.fetchAddressByService(serviceId);

//       // Map each SP address to its ServiceProviderModel
//       _selectedProviders = spAddresses.map((addr) => addr).toList();

//     } catch (e) {
//       _errorMessage = e.toString();
//       _selectedProviders = [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clear() {
//     _selectedProviders = [];
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
