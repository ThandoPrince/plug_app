import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/cancel_shipment_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_reshedule_controler.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';

/// Shared "Cancel Shipment" confirmation dialog.
///
/// Needs a [ShipmentCancelController] above [context]. If a
/// [ShipmentController] (the "My Schedule" list) is also available, it's
/// refreshed automatically after a successful cancel. If it isn't present
/// (e.g. called from [TrackServiceView]) the refresh is silently skipped —
/// use [onCancelled] to run screen-specific logic instead (e.g. pop back).
Future<void> showShipmentCancelDialog({
  required BuildContext context,
  required int shipmentId,
  VoidCallback? onCancelled,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final controller = Provider.of<ShipmentCancelController>(
        dialogContext,
        listen: false,
      );

      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Cancel Shipment",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to cancel this shipment? This action cannot be undone.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientBtn(
                text: "YES, CANCEL",
                btnColor: Colors.red,
                textColor: Colors.white,
                btnHieght: 50,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  await controller.cancelShipment(shipmentId);

                  if (!context.mounted) return;

                  if (controller.success) {
                    try {
                      await Provider.of<ShipmentController>(
                        context,
                        listen: false,
                      ).refresh();
                    } catch (_) {
                      // No ShipmentController above this screen — nothing to refresh.
                    }

                    FlushbarService.success(
                      context,
                      "Shipment cancelled successfully.",
                    );

                    onCancelled?.call();
                  } else {
                    FlushbarService.error(
                      context,
                      controller.errorMessage ?? "Failed to cancel shipment.",
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              GradientBtn(
                text: "NO, KEEP IT",
                btnColor: Kolors.kPrimary,
                textColor: Kolors.kOffWhite,
                btnHieght: 50,
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

/// Shared "Reschedule Shipment" dialog (date + time pickers).
///
/// Same behavior/refresh rules as [showShipmentCancelDialog] — use
/// [onRescheduled] for any screen-specific follow-up.
Future<void> showShipmentRescheduleDialog({
  required BuildContext context,
  required int shipmentId,
  VoidCallback? onRescheduled,
}) {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final controller = Provider.of<ShipmentRescheduleController>(
        dialogContext,
        listen: false,
      );

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Reschedule Shipment",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DATE PICKER
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TIME PICKER
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedTime == null
                          ? "Select Time"
                          : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientBtn(
                    text: "RESCHEDULE",
                    btnColor: Colors.blue,
                    textColor: Colors.white,
                    btnHieght: 50,
                    btnWidth: double.infinity,
                    radius: 12,
                    onTap: () async {
                      if (selectedDate == null || selectedTime == null) {
                        FlushbarService.warning(
                          context,
                          "Please select both a date and time.",
                        );
                        return;
                      }

                      final formattedDate =
                          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                      final formattedTime =
                          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

                      Navigator.of(dialogContext).pop();

                      final success = await controller.rescheduleShipment(
                        shipmentId: shipmentId,
                        newDate: formattedDate,
                        newTime: formattedTime,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        try {
                          await Provider.of<ShipmentController>(
                            context,
                            listen: false,
                          ).refresh();
                        } catch (_) {
                          // No ShipmentController above this screen — nothing to refresh.
                        }

                        FlushbarService.success(
                          context,
                          "Shipment rescheduled successfully.",
                        );

                        onRescheduled?.call();
                      } else {
                        FlushbarService.error(
                          context,
                          controller.errorMessage ??
                              "Failed to reschedule shipment.",
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  GradientBtn(
                    text: "CANCEL",
                    btnColor: Colors.grey.shade300,
                    textColor: Colors.black,
                    btnHieght: 50,
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
    },
  );
}