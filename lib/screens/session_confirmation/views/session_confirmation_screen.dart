import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClientQrCheckinScreen extends StatelessWidget {
  final int shipmentId;

  const ClientQrCheckinScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientCheckinController()..loadCheckinToken(shipmentId),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Service Check-in",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<ClientCheckinController>(
          builder: (context, controller, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: SafeArea(
                child: _buildContent(context, controller),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientCheckinController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (controller.error != null) {
      return _buildErrorState(controller.error!);
    }

    if (controller.token == null) {
      return _buildErrorState("No check-in token available");
    }

    final price = controller.token!.shipment?.serviceOrdered?.proposalPrice ?? '0.00';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // --- Ticket Design ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // QR Code Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Kolors.kSecondaryLight, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: controller.qrData,
                    size: 220,
                    version: QrVersions.auto,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF263238),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Kolors.kPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "SCAN TO CHECK-IN",
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Kolors.kPrimary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: _TicketDivider(), // Custom dashed divider
                ),
                // Details Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                  child: Column(
                    children: [
                      _buildDetailRow("Amount Due", "R $price", Icons.payments_outlined),
                      const SizedBox(height: 16),
                      _buildDetailRow(
  "Expires In",
  controller.formattedRemaining,
  Icons.timer_outlined,
),

                      const SizedBox(height: 24),
                      Text(
                        "Ask the Service Provider to scan this code to begin the session.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          // Security Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                "Secure Verification Process",
                style: TextStyle(color: Colors.black.withOpacity(0.9), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey.shade300),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade300, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF263238)),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Text(message, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Custom widget for the dashed line in the ticket
class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Kolors.kPrimary, // Matches background
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => const SizedBox(width: 5, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFECEFF1)))),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Kolors.kSecondaryLight, // Matches background
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }
}