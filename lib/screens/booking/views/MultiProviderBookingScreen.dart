import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/create_booking_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/def_add_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/booking/widgets/booking_success_overlay.dart' show BookingSuccessOverlay;
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
  final TextEditingController _proposedPriceController =
      TextEditingController();

  List<File> _bookingImages = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  AddressClientModel? _defaultAddress;

  bool _isSubmitting = false;

  late List<ServiceProviderModel> _selectedProviders;
  late List<CostOfServiceModel> _selectedCosts;

  @override
  void initState() {
    super.initState();

    _selectedProviders = List<ServiceProviderModel>.from(widget.selectedProviders);
    _selectedCosts = List<CostOfServiceModel>.from(widget.selectedCosts);

    Future.microtask(() async {
      
      
      final defAddCtrl = Provider.of<DefAddController>(context, listen: false);

      await defAddCtrl.fetchAddresses();

      final AddressClientModel? found = defAddCtrl.addresses.isNotEmpty
          ? defAddCtrl.addresses.firstWhere(
              (a) => a.isDefault == true,
              orElse: () => defAddCtrl.addresses.first,
            )
          : null;

      if (!mounted) return;

      if (found != null) {
        setState(() {
          _defaultAddress = found;
        });
      }
    });
  }

  void _removeProviderAt(int index) {
    if (index < 0 || index >= _selectedProviders.length) return;

    setState(() {
      _selectedProviders.removeAt(index);

      if (index < _selectedCosts.length) {
        _selectedCosts.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _proposedPriceController.dispose();
    super.dispose();
  }

  double? get averagePrice {
    final relevantCosts =
        _selectedCosts.where((cost) => cost.basePrice != null).toList();

    if (relevantCosts.isEmpty) return null;

    final totalBasePrice = relevantCosts.fold<double>(
      0,
      (sum, cost) => sum + (cost.basePrice ?? 0),
    );

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

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_proposedPriceController.text.isNotEmpty) {
        final parsed = double.tryParse(_proposedPriceController.text);
        if (parsed != null) {
          _proposedPriceController.text = parsed.toStringAsFixed(2);
        }
      }

      final bookingController = context.read<BookingController>();
      final session = context.read<AuthSessionController>();

      final success = await bookingController.submitBooking(
        session: session,
        titleController: _titleController,
        notesController: _notesController,
        proposedPriceController: _proposedPriceController,
        selectedDate: _selectedDate,
        selectedTime: _selectedTime,
        defaultAddress: _defaultAddress,
        selectedProviders: _selectedProviders,
        selectedCosts: _selectedCosts,
        serviceId: widget.serviceId,
        bookingImages: _bookingImages,
        averagePrice: averagePrice,
      );

      if (!mounted) return;

if (success) {
  await BookingSuccessOverlay.show(
    context,
    title: "Booking Submitted!",
    message:
        "Amazing work — your booking has been sent successfully. Providers can now review your request and respond.",
    buttonText: "Continue",
  );

  if (!mounted) return;

  setState(() {
    _bookingImages = [];
    _selectedDate = null;
    _selectedTime = null;
  });

  // The overlay's own button already switched tabs and called
  // context.go('/entryPoint') — but since this booking screen was
  // pushed imperatively (Navigator.push), it isn't part of go_router's
  // declarative page stack, so go() alone doesn't remove it. Pop it
  // explicitly so the user actually lands back on EntryPoint instead of
  // seeing this screen still on top until they hit back.
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}else {
  FlushbarService.error(
    context,
    bookingController.errorMessage ?? "Failed to submit booking",
  );
}
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
        centerTitle: true,
        backgroundColor: Kolors.kPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        ),
        child: SafeArea(
          child: MultiProviderBookingBody(
            handlePermission: BookingUtils.handlePermission,
            titleController: _titleController,
            selectedProviders: _selectedProviders,
            selectedCosts: _selectedCosts,
            serviceId: widget.serviceId,
            negotiatedPriceController: _proposedPriceController,
            notesController: _notesController,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            onPickDate: _pickDate,
            onPickTime: _pickTime,
            onSubmitBooking: _submitBooking,
            defaultAddress: _defaultAddress,
            isSubmitting: _isSubmitting,
            onImagesChanged: (List<File> images) {
              setState(() {
                _bookingImages = images;
              });
            },
            onRemoveProvider: _removeProviderAt,
          ),
        ),
      ),
    );
  }
}