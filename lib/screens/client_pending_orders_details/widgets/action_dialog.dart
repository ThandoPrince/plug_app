import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/cancel_order_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';

/// Shared "Cancel Order" confirmation dialog.
///
/// Needs a [CancelOrderController] above [context]. If a
/// [ClientPendingOrdersController] (the pending-orders list) is also
/// available, it's refreshed automatically after a successful cancel — if
/// it isn't present (e.g. called straight from the list itself, where a
/// refresh isn't needed) it's silently skipped. Use [onCancelled] for any
/// screen-specific follow-up — e.g. the detail screen refreshes its own
/// booking and pops back.
Future<void> showCancelOrderDialog({
  required BuildContext context,
  required int orderId,
  Future<void> Function()? onCancelled,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final controller = Provider.of<CancelOrderController>(
        dialogContext,
        listen: false,
      );

      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Cancel Order",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to cancel this order? This action cannot be undone.",
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
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  final success = await controller.cancelOrder(
                    orderId: orderId,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    try {
                      await Provider.of<ClientPendingOrdersController>(
                        context,
                        listen: false,
                      ).fetchPendingOrders(forceRefresh: true);
                    } catch (_) {
                      // No pending-orders list above this screen — nothing to refresh.
                    }

                    FlushbarService.success(
                      context,
                      "Order cancelled successfully.",
                    );

                    await onCancelled?.call();
                  } else {
                    FlushbarService.error(
                      context,
                      "Failed to cancel order.",
                    );
                  }
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