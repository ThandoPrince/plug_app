import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/pending_orders_details_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_detail_ctrl.dart';


class PendingOrderDetailScreen extends StatelessWidget {
  final int orderId;
  const PendingOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Kolors.kPrimary ?? Colors.blue.shade800;
    final Color secondaryColor = Kolors.kSecondaryLight ?? Colors.blue.shade200;

    return ChangeNotifierProvider(
      create: (_) =>
          ClientPendingOrdersDetailCtrl()..fetchBookingByOrderID(orderId),
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text(
            "Order Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor.withOpacity(0.9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Consumer<ClientPendingOrdersDetailCtrl>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (controller.errorMessage != null || controller.booking == null) {
                final message = controller.errorMessage ??
                    "No booking details found for this ID.";
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              final booking = controller.booking!;
              return PendingOrderDetailBody(booking: booking, orderId: orderId);
            },
          ),
        ),
      ),
    );
  }
}
