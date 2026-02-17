import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:provider/provider.dart';

class BookingService {
  static Future<void> submitBooking({
    required BuildContext context,
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
    if (titleController.text.trim().isEmpty) {
      FlushbarService.warning(context, "Please enter a title for the booking");
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      FlushbarService.warning(context, "Please select a date and time for the booking");
      return;
    }

    if (defaultAddress == null) {
      FlushbarService.warning(context, "Please select a delivery address");
      return;
    }

    if (notesController.text.trim().isEmpty) {
      FlushbarService.warning(context, "Please enter notes for the booking");
      return;
    }

    if (bookingImages.isEmpty) {
      FlushbarService.warning(context, "Please upload at least one image for the booking");
      return;
    }

    if (proposedPriceController.text.trim().isEmpty || proposedPriceController.text.trim() == "0") {
      FlushbarService.warning(context, "Please enter a proposed price for the booking");
      return;
    }

    final scheduled = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    double? negotiatedPrice;
    if (proposedPriceController.text.trim().isNotEmpty || proposedPriceController.text.trim() != "0") {
      negotiatedPrice = double.tryParse(proposedPriceController.text.replaceAll(',', ''));
      
    } 
    final session = context.read<AuthSessionController>();
    final email = session.email;

    final invitedProvidersEmails =
        selectedProviders.map((sp) => sp.spProfile.emailAddress).toList();
        final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/bookings/order_a_service/'),
    );

    final timeString =
        "${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}";
    final dateString =
        "${scheduled.year.toString().padLeft(4, '0')}-"
        "${scheduled.month.toString().padLeft(2, '0')}-"
        "${scheduled.day.toString().padLeft(2, '0')}";

    request.fields['client'] = email.toString();
    request.fields['title'] = titleController.text.trim();
    request.fields['notes'] = notesController.text;
    request.fields['requested_date_time'] = timeString;
    request.fields['requested_date'] = dateString;
    request.fields['delivery_address'] = defaultAddress.address.placeId.toString();
    request.fields['status'] = "pending";
    request.fields['is_broadcasted'] = "true";
    request.fields['service_required'] = serviceId.toString();
    request.fields['base_price'] = averagePrice != null ? averagePrice.toString() : "0.0";

    if (negotiatedPrice != null) {
      request.fields['proposal_price'] = negotiatedPrice.toString();
      request.fields['is_negotiated'] = "true";
    }
    if (averagePrice != null) {
      request.fields['base_price'] = averagePrice.toString();
    }

    for (var email in invitedProvidersEmails) {
      request.files.add(
        http.MultipartFile.fromString('invited_providers', email),
      );
    }

    for (final file in bookingImages) {
      request.files.add(
        await http.MultipartFile.fromPath('service_pictures', file.path),
      );
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      FlushbarService.success(context, "Booking submitted successfully");
      titleController.clear();
      notesController.clear();
      proposedPriceController.clear();
    } else {
      FlushbarService.error(context, "Error ${response.statusCode}: $respStr");
    }
  }
}
