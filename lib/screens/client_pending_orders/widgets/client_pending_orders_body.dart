import 'package:flutter/material.dart';

import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/views/client_pending_orders_details_screen.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_dialog.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_sheet.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/action_tile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
        icon: Icons.cloud_off_outlined,
        title: "Failed to load orders",
        subtitle: controller.errorMessage!,
      );
    } else if (filteredOrders.isEmpty) {
      content = _buildStateView(
        icon: Icons.assignment_turned_in_outlined,
        title: "No Pending Orders",
        subtitle: "You have no outstanding requests right now ",
      );
    } else {
      content = RefreshIndicator(
        color: Kolors.kPrimary,
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
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
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

    if (status.contains('pending')) {
  // Waiting for action / response
  statusColor = Colors.orange.shade700;
  statusIcon = Icons.access_time_rounded;
} else if (status.contains('in-negotiation')) {
  // Active negotiation
  statusColor = Colors.blue.shade700;
  statusIcon = Icons.forum_outlined;
} else if (status.contains('rescheduled')) {
  // Appointment/request moved to another time
  statusColor = Colors.purple.shade700;
  statusIcon = Icons.event_repeat_rounded;
} else if (status.contains('declined') || status.contains('rejected')) {
  // Rejected / declined
  statusColor = Colors.red.shade700;
  statusIcon = Icons.cancel_outlined;
} else {
  // Unknown / other status
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
                // Title and Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.title?.toUpperCase() ?? "NEW SERVICE REQUEST",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
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