import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/def_add_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/booking/widgets/booking_service_widget.dart';
import 'package:flutter_application_1/screens/booking/widgets/booking_utils.dart';
import 'package:flutter_application_1/screens/booking/widgets/multiproviderbookingbody.dart';

import 'package:provider/provider.dart';

class MultiProviderBookingScreen extends StatefulWidget {
  final List<ServiceProviderModel> selectedProviders;
  final List<CostOfServiceModel> selectedCosts;
  final int serviceId;

  const MultiProviderBookingScreen({
    super.key,
    required this.selectedProviders,
    required this.selectedCosts,
    required this.serviceId,
  });

  @override
  State<MultiProviderBookingScreen> createState() =>
      _MultiProviderBookingScreenState();
}

class _MultiProviderBookingScreenState extends State<MultiProviderBookingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _proposedPriceController = TextEditingController();
 
  List<File> _bookingImages = [];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  AddressClientModel? _defaultAddress;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final defAddCtrl = Provider.of<DefAddController>(context, listen: false);
      await defAddCtrl.fetchAddresses('t.p.tshabalala98@gmail.com');
      final AddressClientModel? found = defAddCtrl.addresses.isNotEmpty
          ? defAddCtrl.addresses.firstWhere(
              (a) => a.isDefault == true,
              orElse: () => defAddCtrl.addresses.first,
            )
          : null;
      if (found != null) {
        setState(() {
          _defaultAddress = found;
        });
      }
    });
  }

  double? get averagePrice {
    final relevantCosts = widget.selectedCosts
        .where((cost) =>
            cost.service.serviceId == widget.serviceId && cost.basePrice != null)
        .toList();
    if (relevantCosts.isEmpty) return null;
    final totalBasePrice =
        relevantCosts.fold<double>(0, (sum, cost) => sum + (cost.basePrice ?? 0));
    return totalBasePrice / relevantCosts.length;
  }



  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    final pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }


  // --- Submit booking using the service file ---
  Future<void> _submitBooking() async {
    await BookingService.submitBooking(
      context: context,
      titleController: _titleController,
      notesController: _notesController,
      proposedPriceController: _proposedPriceController,
      selectedDate: _selectedDate,
      selectedTime: _selectedTime,
      defaultAddress: _defaultAddress,
      selectedProviders: widget.selectedProviders,
      selectedCosts: widget.selectedCosts,
      serviceId: widget.serviceId,
      bookingImages: _bookingImages,
      averagePrice: averagePrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Service Booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: MultiProviderBookingBody(
            handlePermission: BookingUtils.handlePermission, 
            titleController: _titleController,
            selectedProviders: widget.selectedProviders,
            selectedCosts: widget.selectedCosts,
            serviceId: widget.serviceId,
            negotiatedPriceController: _proposedPriceController,
            notesController: _notesController,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            onPickDate: _pickDate,
            onPickTime: _pickTime,
            onSubmitBooking: _submitBooking,
            defaultAddress: _defaultAddress,
            onImagesChanged: (List<File> images) {
              setState(() {
                _bookingImages = images;
              });
            },
          ),
        ),
      ),
    );
  }
}
