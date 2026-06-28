import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/cancel_order_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/views/edit_pending_order_screen.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/pending_orders_details_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_detail_ctrl.dart';

class PendingOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const PendingOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<PendingOrderDetailScreen> createState() => _PendingOrderDetailScreenState();
}

class _PendingOrderDetailScreenState extends State<PendingOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Kolors.kPrimary ?? Colors.blue.shade800;
    final secondaryColor = Kolors.kSecondaryLight ?? Colors.blue.shade200;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ClientPendingOrdersDetailCtrl()
            ..fetchBookingByOrderID(widget.orderId),
        ),
        ChangeNotifierProvider(
          create: (_) => CancelOrderController(),
        ),
      ],
      child: Consumer2<
          ClientPendingOrdersDetailCtrl,
          CancelOrderController>(
        builder: (context, detailCtrl, cancelCtrl, child) {
          final hasData = !detailCtrl.isLoading &&
              detailCtrl.errorMessage == null &&
              detailCtrl.booking != null;

          return Scaffold(
            backgroundColor: primaryColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              elevation: 0,
              title: const Text(
                "Order Details",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (hasData)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'cancel') {
                        _showCancelDialog(
                          context,
                          detailCtrl,
                          cancelCtrl,
                          widget.orderId,
                        );
                      }

                      if (value == 'edit'){
  final updated =  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditOrderScreen(
        booking: detailCtrl.booking!,
      ),
    ),
  );

  if (updated == true) {
     detailCtrl.fetchBookingByOrderID(widget.orderId);
  }
}
                    },
                    
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit Order'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Cancel Order',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight], // Deep brand gradient
                  ),
              ),
              child: Builder(
                builder: (_) {
                  if (detailCtrl.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (detailCtrl.errorMessage != null ||
                      detailCtrl.booking == null) {
                    return ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: [
    const SizedBox(height: 120),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_busy_outlined,
          size: 100,
          color: Colors.white.withOpacity(0.6),
        ),
        const SizedBox(height: 20),

        const Text(
          "Booking Not Found",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            detailCtrl.errorMessage ??
                "No booking found. Please try again or refresh the page.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  ],
);
                  }

                  return PendingOrderDetailBody(
                    booking: detailCtrl.booking!,
                    orderId: widget.orderId,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    ClientPendingOrdersDetailCtrl detailCtrl,
    CancelOrderController cancelCtrl,
    int orderId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
          "Are you sure you want to cancel this order?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            children: [
              GradientBtn(
                text: "No, Keep It",
                btnColor: Kolors.kPrimary,
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
              SizedBox(height: 10.h),
              GradientBtn(
                text: "Yes, Cancel",
                textColor: Colors.black,
                btnColor: Colors.grey.shade300,
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  final success = await cancelCtrl.cancelOrder(
                    orderId: orderId,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    // refresh detail screen
                    await detailCtrl.fetchBookingByOrderID(orderId);

                    // refresh LIST screen (safe lookup)
                    final listCtrl = context.read<ClientPendingOrdersController>();

                    await listCtrl.fetchPendingOrders();

                    FlushbarService.success(
                      context,
                      "Order cancelled successfully",
                    );

                    await Future.delayed(
                      const Duration(milliseconds: 400),
                    );

                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pop();
                    }
                  } else {
                    FlushbarService.error(
                      context,
                      "Failed to cancel order",
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}