
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/screens/schedule/widgets/shipment_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/screens/track_shipment/views/track_service_screen.dart';


class ScheduledShipmentsScreen extends StatefulWidget {
  const ScheduledShipmentsScreen({super.key});

  @override
  State<ScheduledShipmentsScreen> createState() =>
      _ScheduledShipmentsScreenState();
}

class _ScheduledShipmentsScreenState extends State<ScheduledShipmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentController>().fetchShipmentsByClientEmail(
            't.p.tshabalala98@gmail.com',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ShipmentController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Schedule',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(child: _buildBody(controller)),
        ],
      ),
    );
  }

  Widget _buildBody(ShipmentController controller) {
    if (controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (controller.error != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            controller.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (controller.shipments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 100, color: Colors.white.withOpacity(0.6)),
            const SizedBox(height: 20),
            const Text(
              'No Orders Scheduled!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      itemCount: controller.shipments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (_, index) {
        return ShipmentScheduleCard(shipment: controller.shipments[index]);
      },
    );
  }
}
