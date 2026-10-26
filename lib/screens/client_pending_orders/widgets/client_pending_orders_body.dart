import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/global_util/services/widgets/refresh_indicator_widget.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/views/client_pending_orders_details_screen.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_dialog.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_sheet.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_tile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';

class ClientPendingOrdersBody extends StatelessWidget {
  final ClientPendingOrdersController controller;
  final String selectedStatus;

  const ClientPendingOrdersBody({
    super.key,
    required this.controller,
    required this.selectedStatus,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final filteredOrders = selectedStatus == "All"
        ? controller.pendingOrders
        : controller.pendingOrders.where((order) {
            final status = order.status?.toLowerCase() ?? "";

            switch (selectedStatus) {
              case "Pending":
                return status.contains("pending");

              case "In-Negotiation":
                return status.contains("in-negotiation");

              case "Rescheduled":
                return status.contains("rescheduled");

              default:
                return true;
            }
          }).toList();

    if (controller.isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (controller.errorMessage != null) {
      content = _buildStateView(
        context: context,
        icon: Icons.cloud_off_outlined,
        title: "Failed to load orders",
        subtitle: controller.errorMessage!,
        onRefresh: () => controller.fetchPendingOrders(forceRefresh: true),
        showActionButton: false,
      );
    } else if (filteredOrders.isEmpty) {
      content = _buildStateView(
        context: context,
        icon: Icons.assignment_turned_in_outlined,
        title: "No Pending Orders",
        subtitle: "You have no outstanding requests right now",
        onRefresh: () => controller.fetchPendingOrders(forceRefresh: true),
        showActionButton: true,
      );
    } else {
      content = GenericLoadingRefresh(
        isLoading: controller.isLoading,
        onRefresh: () => controller.fetchPendingOrders(forceRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderItemCard(context, order);
          },
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: content,
    );
  }

  Widget _buildStateView({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function() onRefresh,
    required bool showActionButton,
  }) {
    return RefreshIndicator(
      color: Kolors.kPrimary,
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 90,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Subtitle text made bigger as requested
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (showActionButton) ...[
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () => context.push("/viewAllServices"),
                        icon: const Icon(Icons.explore_outlined, color: Colors.white, size: 20),
                        label: const Text(
                          "Explore Services",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────── LONG-PRESS ACTIONS ─────────────────────────────

  void _showOrderActions(BuildContext context, OrderServiceModel order) {
    showActionsSheet(
      context: context,
      title: "Order Actions",
      tiles: [
        ActionTile(
          icon: Icons.cancel,
          label: "Cancel Order",
          color: Colors.red,
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);

            if (order.orderId != null) {
              showCancelOrderDialog(
                context: context,
                orderId: order.orderId!,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildOrderItemCard(BuildContext context, OrderServiceModel order) {
    final status = order.status?.toLowerCase() ?? 'pending';
    Color statusColor;
    IconData statusIcon;

    final unreadCount = order.orderId != null
        ? context.watch<NegotiationBadgeStore>().countForOrder(order.orderId!)
        : 0;

    if (status.contains('pending')) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.access_time_rounded;
    } else if (status.contains('in-negotiation')) {
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.forum_outlined;
    } else if (status.contains('rescheduled')) {
      statusColor = Colors.purple.shade700;
      statusIcon = Icons.event_repeat_rounded;
    } else if (status.contains('declined') || status.contains('rejected')) {
      statusColor = Colors.red.shade700;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.info_outline;
    }

    final serviceName =
        order.serviceRequired?.serviceName ?? "Service Not Specified";
    final orderIdPartial = order.orderId != null
        ? order.orderId.toString().substring(
            0,
            order.orderId.toString().length > 8
                ? 8
                : order.orderId.toString().length)
        : "N/A";

    final requestedDate = order.requestedDateTime != null
        ? DateFormat("dd MMM yyyy, HH:mm").format(order.requestedDateTime!)
        : "Date N/A";

    return GestureDetector(
      onLongPress: () => _showOrderActions(context, order),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            if (order.orderId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PendingOrderDetailScreen(orderId: order.orderId!),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.title?.toUpperCase() ?? "NEW SERVICE REQUEST",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.status?.toUpperCase() ?? "UNKNOWN",
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -7,
                            right: -7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16, thickness: 0.5),
                _buildInfoRow(
                  context,
                  icon: Icons.design_services_outlined,
                  label: 'Service',
                  value: serviceName,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Requested Date',
                  value: requestedDate,
                ),
                const SizedBox(height: 6),
                Text(
                  'Order ID: #$orderIdPartial',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Kolors.kDark.withOpacity(0.8)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}