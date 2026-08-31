
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/deactivate_address_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';

/// Shared "Delete Address" confirmation dialog.
///
/// Needs a [DeactivateAddressController] above [context]. After a
/// successful delete, refreshes [AddressClientCtrl] and the map marker
/// automatically. Use [onDeleted] for any screen-specific follow-up
/// (e.g. clearing a selection).
Future<void> showDeleteAddressDialog({
  required BuildContext context,
  required int addressId,
  Future<void> Function()? onDeleted,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final controller = Provider.of<DeactivateAddressController>(
        dialogContext,
        listen: false,
      );

      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Delete Address",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this address? This action cannot be undone.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientBtn(
                text: "YES, DELETE",
                btnColor: Colors.red,
                textColor: Colors.white,
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  final success = await controller.deactivateAddress(
                    context,
                    addressId,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    try {
                      final addressCtrl = Provider.of<AddressClientCtrl>(
                        context,
                        listen: false,
                      );
                      addressCtrl.resetCache();
                      await addressCtrl.refresh();

                      if (!context.mounted) return;

                      await Provider.of<GoogleMapMarkerController>(
                        context,
                        listen: false,
                      ).showDefaultAddress(force: true);
                    } catch (_) {
                      // No address list / map above this screen — nothing to refresh.
                    }

                    if (!context.mounted) return;

                    await onDeleted?.call();
                  }
                  // deactivateAddress already shows its own error Flushbar.
                },
              ),
              SizedBox(height: 10.h),
              GradientBtn(
                text: "NO, KEEP IT",
                btnColor: Kolors.kPrimary,
                textColor: Kolors.kOffWhite,
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ],
      );
    },
  );
}