import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/schedule/widgets/go_to_schedule_helper.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/detail_row.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/ticket_divider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';


class ClientQrCheckinContent extends StatelessWidget {
  const ClientQrCheckinContent({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
    goToSchedule(context);
    return false;
  },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => goToSchedule(context),
      ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Service Check-in",
            style:
                TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
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
              child: SafeArea(child: _buildContent(controller)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ClientCheckinController controller) {
    if (controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (controller.error != null) {
      return _buildErrorState(controller.error!);
    }

    if (controller.token == null) {
      return _buildErrorState("No check-in token available");
    }

    final price =
        controller.token!.shipment?.serviceOrdered?.proposalPrice ??
            '0.00';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Kolors.kSecondaryLight, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: controller.qrData,
                    size: 220,
                    version: QrVersions.auto,
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
                  child: TicketDivider(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                  child: Column(
                    children: [
                      DetailRow(
                        label: "Amount Due",
                        value: "R $price",
                        icon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 16),
                      DetailRow(
                        label: "Expires In",
                        value: controller.formattedRemaining,
                        icon: Icons.timer_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Text(message,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
