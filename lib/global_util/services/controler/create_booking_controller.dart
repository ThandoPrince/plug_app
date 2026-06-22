import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/create_booking_api.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';



class BookingController with ChangeNotifier {
 

  final BookingApiHelper apiHelper = BookingApiHelper();



  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> submitBooking({
    required AuthSessionController session,
    required TextEditingController titleController,
    required TextEditingController notesController,
    required TextEditingController proposedPriceController,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required AddressClientModel? defaultAddress,
    required List<ServiceProviderModel> selectedProviders,
    required List<CostOfServiceModel> selectedCosts,
    required int serviceId,
    required List<File> bookingImages,
    required double? averagePrice,
  }) async {
    clearMessages();

    final title = titleController.text.trim();
    final notes = notesController.text.trim();
    final proposedTextRaw = proposedPriceController.text.trim();
    final proposedText = proposedTextRaw.replaceAll(',', '');

    if (title.isEmpty) {
      _errorMessage = "Please enter a title for the booking";
      notifyListeners();
      return false;
    }

    if (selectedDate == null || selectedTime == null) {
      _errorMessage = "Please select a date and time for the booking";
      notifyListeners();
      return false;
    }

    if (defaultAddress == null) {
      _errorMessage = "Please select a delivery address";
      notifyListeners();
      return false;
    }

    if (notes.isEmpty) {
      _errorMessage = "Please enter notes for the booking";
      notifyListeners();
      return false;
    }

    if (bookingImages.isEmpty) {
      _errorMessage = "Please upload at least one image for the booking";
      notifyListeners();
      return false;
    }

    if (proposedTextRaw.isEmpty || proposedTextRaw == "0") {
      _errorMessage = "Please enter a proposed price for the booking";
      notifyListeners();
      return false;
    }

    final negotiatedPrice = double.tryParse(proposedText);
    if (negotiatedPrice == null || negotiatedPrice <= 0) {
      _errorMessage = "Please enter a valid proposed price";
      notifyListeners();
      return false;
    }

    if (serviceId <= 0) {
      _errorMessage = "Invalid service selected";
      notifyListeners();
      return false;
    }

    final scheduled = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final minimumAllowed = DateTime.now().add(const Duration(hours: 1));
    if (scheduled.isBefore(minimumAllowed)) {
      _errorMessage = "Booking must be at least 1 hour from now";
      notifyListeners();
      return false;
    }

    
    final id = session.clientId;
    

    final invitedProvidersEmails = selectedProviders
    .map((sp) => sp.spProfile?.id)
    .where((id) => id != null)
    .cast<int>()
    .toSet()
    .toList();

    if (invitedProvidersEmails.isEmpty) {
      _errorMessage = "Please select at least one provider";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    final result = await apiHelper.submitBooking(
      clientId: id.toString(),
      title: title,
      notes: notes,
      scheduled: scheduled,
      defaultAddress: defaultAddress,
      selectedProviders: selectedProviders,
      serviceId: serviceId,
      bookingImages: bookingImages,
      averagePrice: averagePrice,
      negotiatedPrice: negotiatedPrice,
    );

    _setLoading(false);

    if (result.success) {
      _successMessage = result.message;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _successMessage = null;
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }
}