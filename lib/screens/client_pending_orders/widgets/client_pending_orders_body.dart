import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/screens/client_pending_orders/client_pending_orders_orders/views/client_pending_orders_orders_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';

class ClientPendingOrdersBody extends StatelessWidget {
   final String clientEmail;
  const ClientPendingOrdersBody({super.key, required this.clientEmail});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientPendingOrdersController>(
      builder: (context, controller, child) {
        Widget content;

        if (controller.isLoading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage != null) {
          content = _buildStateWidget(
            icon: Icons.cloud_off_outlined,
            message:
                "Failed to load orders: ${controller.errorMessage!}. Pull down to retry.",
            context: context,
          );
        } else if (controller.pendingOrders.isEmpty) {
          content = _buildStateWidget(
            icon: Icons.assignment_turned_in_outlined,
            message:
                "You have no outstanding pending requests. Great job! 🎉",
            context: context,
          );
        } else {
          content = RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () =>
                controller.fetchPendingOrders(clientEmail),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: controller.pendingOrders.length,
              itemBuilder: (context, index) {
                final order = controller.pendingOrders[index];
                return _buildOrderItemCard(context, order);
              },
            ),
          );
        }

        // Wrap everything in a Container
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: content,
        );
      },
    );
  }

  Widget _buildStateWidget({
    required IconData icon,
    required String message,
    required BuildContext context,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(BuildContext context, OrderServiceModel order) {
    final status = order.status?.toLowerCase() ?? 'pending';
    Color statusColor;
    IconData statusIcon;

    if (status.contains('pending')) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.access_time;
    } else if (status.contains('accepted')) {
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.check_circle_outline;
    } else if (status.contains('declined') || status.contains('rejected')) {
      statusColor = Colors.red.shade700;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.info_outline;
    }

    final serviceName = order.serviceRequired?.serviceName ?? "Service Not Specified";
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

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
                      if (order.orderId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PendingOrderDetailScreen(orderId: order.orderId!),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          order.status ?? "UNKNOWN",
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
