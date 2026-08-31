import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/shimmers/order_body_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/cancel_order_controller.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/views/edit_pending_order_screen.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_dialog.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_sheet.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_tile.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/pending_orders_details_widget.dart';
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
  State<PendingOrderDetailScreen> createState() =>
      _PendingOrderDetailScreenState();
}

class _PendingOrderDetailScreenState extends State<PendingOrderDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detailCtrl = context.read<ClientPendingOrdersDetailCtrl>();

      // Only refetch if we don't already have this exact order loaded —
      // otherwise reopening the same order's detail screen (e.g.
      // navigating back and forward, or a rebuild triggered elsewhere)
      // would silently kick off a redundant network call and briefly
      // flash the skeleton over data that was already correct.
      final alreadyLoaded = detailCtrl.booking?.orderId == widget.orderId &&
          detailCtrl.errorMessage == null;

      if (!alreadyLoaded) {
        detailCtrl.fetchBookingByOrderID(widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Kolors.kPrimary ?? Colors.blue.shade800;

    return MultiProvider(
      providers: [
        // ClientPendingOrdersDetailCtrl is intentionally NOT provided
        // here — it's already an app-level singleton declared in
        // main.dart. Creating a second instance per screen visit was
        // exactly what caused the refetch-on-every-open behavior: each
        // new ChangeNotifierProvider(create: ...) built a fresh
        // controller and immediately called fetchBookingByOrderID on
        // it, discarding whatever the app-level instance already had.
        ChangeNotifierProvider(
          create: (_) => CancelOrderController(),
        ),
      ],
      child: Consumer2<ClientPendingOrdersDetailCtrl, CancelOrderController>(
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
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showOrderActions(context, detailCtrl),
                  ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Builder(
                builder: (_) {
                  if (detailCtrl.isLoading) {
                    return const OrderBodySkeleton();
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
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

  // ───────────────────────────── ACTIONS ─────────────────────────────

  void _showOrderActions(
    BuildContext context,
    ClientPendingOrdersDetailCtrl detailCtrl,
  ) {
    showActionsSheet(
      context: context,
      title: "Order Actions",
      tiles: [
        ActionTile(
          icon: Icons.edit,
          label: "Edit Order",
          color: Colors.blue,
          onTap: () async {
            Navigator.pop(context);

            final updated = await Navigator.push(
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
          },
        ),
        ActionTile(
          icon: Icons.cancel,
          label: "Cancel Order",
          color: Colors.red,
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);

            showCancelOrderDialog(
              context: context,
              orderId: widget.orderId,
              onCancelled: () async {
                await detailCtrl.fetchBookingByOrderID(widget.orderId);
                await Future.delayed(const Duration(milliseconds: 400));
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
            );
          },
        ),
      ],
    );
  }
}