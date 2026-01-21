import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/create_booking_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';

class BookingController with ChangeNotifier {
  final BookingApiService apiService;

  BookingController({required this.apiService});

  OrderServiceModel? _currentBooking;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  OrderServiceModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Create a booking (POST) from an OrderService object
  Future<void> createBooking(OrderServiceModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await apiService.createBooking(booking);
      _currentBooking = result;
      if (kDebugMode) {
        print('Booking created successfully: $_currentBooking');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a booking from a JSON payload
  Future<void> createBookingFromJson(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await apiService.createBookingFromJson(payload);
      _currentBooking = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear booking data and error messages
  void clear() {
    _currentBooking = null;
    _errorMessage = null;
    notifyListeners();
  }
}
