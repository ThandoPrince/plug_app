import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/const/services/cost_of_servicebyemail_api.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_addesses_controller.dart';
import 'package:flutter_application_1/screens/booking/views/MultiProviderBookingScreen.dart';

class CreateServiceWidget extends StatelessWidget {
  const CreateServiceWidget({super.key});

  /// 🔒 Validation logic extracted
  String? _validateBeforeCreate(HereMapMarkerController mapCtrl) {
   

    if (mapCtrl.selectedServiceId == null) {
      return "Please select a service to proceed.";
    }
     if (mapCtrl.visibleProviders.isEmpty && mapCtrl.selectedServiceId != null ) {
      return "Providers may not be availabe for the selected service.";
    }

    return null; // ✅ All good
  }

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<HereMapMarkerController>();
    final spByAddrCtrl =
        context.read<SPByAddressController>();

    final bool isEnabled = mapCtrl.visibleProviders.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        /// 🔍 Run validation
        final validationMessage = _validateBeforeCreate(mapCtrl);

        if (validationMessage != null) {
          FlushbarService.warning(
            context,
            validationMessage,
            position: FlushbarPosition.BOTTOM,
          );
          return;
        }

        final selectedServiceId = mapCtrl.selectedServiceId!;

        try {
          /// ⏳ Loader
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          /// 🔍 Fetch providers
          await spByAddrCtrl.fetchFromVisibleMarkers(mapCtrl);

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
          final emails = spByAddrCtrl.serviceProviders
              .map((sp) => sp.spProfile.emailAddress)
              .whereType<String>()
              .toList();

          final selectedCosts =
              await CostOfServiceByEmailApi.fetchCostsByEmails(emails);

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
          Navigator.of(context).pop();

          FlushbarService.error(
            context,
            "Failed to load service providers. Please try again.",
            position: FlushbarPosition.BOTTOM,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
          backgroundColor: isEnabled
              ? Kolors.kOffWhite.withOpacity(.3)
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
