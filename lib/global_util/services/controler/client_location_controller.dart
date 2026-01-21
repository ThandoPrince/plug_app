import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/client_services/client_address_api.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends ChangeNotifier {
  Position? _currentPosition;
  String? _locationError;
  bool _isNearHome = false;
  List<ClientAddressModel> _addresses = [];

  Position? get currentPosition => _currentPosition;
  String? get locationError => _locationError;
  bool get isNearHome => _isNearHome;
  List<ClientAddressModel> get addresses => _addresses;

  // Added alias getter for savedAddresses
  List<ClientAddressModel> get savedAddresses => _addresses;

  // Request location permission
  Future<bool> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _locationError = "Location permission permanently denied";
      notifyListeners();
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationError = "Location permission denied";
        notifyListeners();
        return false;
      }
    }

    return true;
  }

  // Get current GPS position
  Future<void> fetchCurrentLocation() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _locationError = null;
    } catch (e) {
      _locationError = "Failed to get location: $e";
    }

    notifyListeners();
  }

  // Fetch addresses from backend
  Future<void> loadAddresses(String email) async {
    try {
      _addresses = await AddressApi.getClientAddresses(email);
      notifyListeners();
    } catch (e) {
      _locationError = "Failed to load addresses: $e";
      notifyListeners();
    }
  }

  // Match current location with any saved address
  void verifyProximityToSavedAddresses({double radiusInMeters = 200}) {
    if (_currentPosition == null || _addresses.isEmpty) {
      _isNearHome = false;
      notifyListeners();
      return;
    }

    for (var address in _addresses) {
      if (address.latitude != null && address.longitude != null) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          address.latitude!,
          address.longitude!,
        );

        if (distance <= radiusInMeters) {
          _isNearHome = true;
          notifyListeners();
          return;
        }
      }
    }

    _isNearHome = false;
    notifyListeners();
  }
}
