import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/const/services/cost_of_servicebyemail_api.dart';
// Imports for both map controllers

import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart'; 
import 'package:flutter_application_1/global_util/services/controler/sp_by_addesses_controller.dart';
import 'package:flutter_application_1/screens/booking/views/MultiProviderBookingScreen.dart';

class CreateServiceWidget extends StatelessWidget {
  const CreateServiceWidget({super.key});

  /// 🔒 Unified Validation logic supporting both map engines
  String? _validateBeforeCreate({
    required int? selectedServiceId,
    required List<dynamic> visibleProviders,
  }) {
    if (selectedServiceId == null) {
      return "Please select a service to proceed.";
    }
    if (visibleProviders.isEmpty) {
      return "Providers may not be available for the selected service/or area.";
    }
    return null; 
  }

  @override
  Widget build(BuildContext context) {
    // Watch both controllers to catch data adjustments regardless of the rendering engine
    final googleMapCtrl = context.watch<GoogleMapMarkerController>();
    final hereMapCtrl = context.watch<HereMapMarkerController>();
    final spByAddrCtrl = context.read<SPByAddressController>();

    // Determine engine priority (uses Google Maps data if available, falls back to HERE Maps)
    
    
 final int? activeServiceId = isHuaweiDevice
    ? hereMapCtrl.selectedServiceId
    : googleMapCtrl.selectedServiceId;

final List<dynamic> currentVisibleProviders = isHuaweiDevice
    ? hereMapCtrl.visibleProviders
    : googleMapCtrl.visibleProviders;

    final bool isEnabled = currentVisibleProviders.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        /// 🔍 Run cross-engine validation
        final validationMessage = _validateBeforeCreate(
          selectedServiceId: activeServiceId,
          visibleProviders: currentVisibleProviders,
        );

        if (validationMessage != null) {
          FlushbarService.warning(
            context,
            validationMessage,
            position: FlushbarPosition.BOTTOM,
          );
          return;
        }

        final selectedServiceId = activeServiceId!;

        try {
          /// ⏳ Loader
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          /// 🔍 Fetch providers via the active controller signature
          if (isHuaweiDevice) {
  await spByAddrCtrl.fetchFromVisibleMarkers(
    hereMapCtrl,
  );
} else {
  await spByAddrCtrl.googlefetchFromVisibleMarkers(
    googleMapCtrl,
  );
}

          if (spByAddrCtrl.serviceProviders.isEmpty) {
            Navigator.of(context).pop();

            FlushbarService.info(
              context,
              "No providers available in the selected area.",
              position: FlushbarPosition.BOTTOM,
            );
            return;
          }

          /// 💰 Fetch costs
          final ids = spByAddrCtrl.serviceProviders
              .map((sp) => int.tryParse(sp.spProfile!.id.toString()))
              .whereType<int>()
              .toList();

          final selectedCosts = await CostOfServiceApi.fetchCostsByEmailsAndService(
            ids,
            selectedServiceId,
          );

          if (!context.mounted) return;
          Navigator.of(context).pop();

          /// 🚀 Navigate
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiProviderBookingScreen(
                selectedProviders: spByAddrCtrl.serviceProviders,
                selectedCosts: selectedCosts,
                serviceId: selectedServiceId,
              ),
            ),
          );
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();
            FlushbarService.error(
              context,
              "Failed to load service providers. Please try again.",
              position: FlushbarPosition.BOTTOM,
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
          backgroundColor: isEnabled
              ? Kolors.kPrimary.withOpacity(.9) // Highlight button color when functional providers are in view
              : Kolors.kOffWhite.withOpacity(.1),
          child: const Icon(
            Icons.add_sharp,
            size: 30,
            color: Kolors.kOffWhite,
          ),
        ),
      ),
    );
  }
}