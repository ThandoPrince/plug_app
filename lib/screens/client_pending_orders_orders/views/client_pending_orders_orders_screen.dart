import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_detail_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/screens/negotiations/views/negotiations_by_orderID.dart'; 
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PendingOrderDetailScreen extends StatelessWidget {
  final int orderId;
  const PendingOrderDetailScreen({super.key, required this.orderId});

  String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "completed":
        return Colors.green.shade700;
      case "in_progress":
        return Colors.amber.shade700;
      case "accepted":
        return Colors.blue.shade700;
      case "declined":
      case "rejected":
        return Colors.red.shade700;
      case "cancelled":
        return Colors.red.shade900;
      default:
        return Colors.orange.shade700; // Pending/Default
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Kolors.kPrimary ?? Colors.blue.shade800;
    final Color secondaryColor = Kolors.kSecondaryLight ?? Colors.blue.shade200;
    final Color primaryTextColor = Kolors.kDark ?? Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;

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
              final statusColor = _getStatusColor(booking.status);
              final displayStatus = (booking.status ?? "PENDING")
                  .replaceAll('_', ' ')
                  .toUpperCase();

              return Container(
                decoration: BoxDecoration(
                  color: Kolors.kWhite ?? Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Status (without icon)
                      _buildHeaderSection(
                          booking.title ?? "SERVICE REQUEST",
                          displayStatus,
                          statusColor,
                          primaryTextColor),
                      const SizedBox(height: 24),

                      // Request Details Card
                      _buildDetailCard(
                        title: "Request Details",
                        icon: Icons.receipt_long_rounded,
                        primaryTextColor: primaryTextColor,
                        children: [
                          _buildIconDetailRow(
                              icon: Icons.work_outline,
                              label: "Service Type",
                              value:
                                  booking.serviceRequired?.serviceName ?? "N/A",
                              color: secondaryTextColor),
                          _buildIconDetailRow(
                              icon: Icons.calendar_today_outlined,
                              label: "Requested On",
                              value: formatDateTime(booking.requestedDateTime),
                              color: secondaryTextColor),
                          _buildIconDetailRow(
                              icon: Icons.attach_money_rounded,
                              label: "Proposal Price",
                              value:
                                  "R ${booking.proposalPrice?.toStringAsFixed(2) ?? "TBD"}",
                              color: statusColor.withOpacity(0.9)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Delivery Address Card
                      _buildDetailCard(
                        title: "Delivery Address",
                        icon: Icons.location_on_outlined,
                        primaryTextColor: primaryTextColor,
                        children: [
                          Text(
                            booking.deliveryAddress?.formattedAddress ?? "N/A",
                            style:
                                TextStyle(fontSize: 15, color: secondaryTextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Notes Card
                      if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                        _buildDetailCard(
                          title: "My Notes",
                          icon: Icons.notes_rounded,
                          primaryTextColor: primaryTextColor,
                          children: [
                            Text(
                              booking.notes!,
                              style: TextStyle(
                                fontSize: 15,
                                color: secondaryTextColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Service Images
                      if (booking.servicePictures != null &&
                          booking.servicePictures!.isNotEmpty)
                        _buildImagesCard(booking, primaryTextColor),

                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          final negotiationCtrl =
                              Provider.of<NegotationByOrderIDController>(context,
                                  listen: false);
                          negotiationCtrl.fetchAllNegotiations(orderId);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: negotiationCtrl,
                                child: NegotiationsByOrderidScreen(orderId: orderId),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              "View Negotiations",
                              style: TextStyle(
                                color: Kolors.kPrimary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
      String title, String status, Color statusColor, Color primaryTextColor) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: primaryTextColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 12),
        // Status badge without icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Kolors.kPrimary),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: (label == "Proposal Price") ? color : Kolors.kDark,
                fontSize: 15,
                fontWeight: (label == "Proposal Price")
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesCard(OrderServiceModel booking, Color primaryTextColor) {
    return _buildDetailCard(
      title: "Service Photos (${booking.servicePictures!.length})",
      icon: Icons.photo_library_outlined,
      primaryTextColor: primaryTextColor,
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: booking.servicePictures!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final imgUrl = booking.servicePictures![index].image;
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imgUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Kolors.kPrimary),
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color primaryTextColor;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Kolors.kPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 24,
              thickness: 1.5,
              color: Color.fromARGB(255, 235, 235, 235),
            ),
            ...children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: child,
                    ))
                ,
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
  required Color primaryTextColor,
}) {
  return _DetailCard(
    title: title,
    icon: icon,
    primaryTextColor: primaryTextColor,
    children: children,
  );
}
