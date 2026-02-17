import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/screens/schedule/widgets/shipment_card.dart';

class ScheduledShipmentsScreen extends StatefulWidget {
  const ScheduledShipmentsScreen({super.key});

  @override
  State<ScheduledShipmentsScreen> createState() =>
      _ScheduledShipmentsScreenState();
}

class _ScheduledShipmentsScreenState extends State<ScheduledShipmentsScreen> {
  
  

  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<AuthSessionController>();
    final email = session.email;
      context
          .read<ShipmentController>()
          .fetchShipmentsByClientEmail(email.toString());
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ShipmentController>().refresh();
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta! > 0 && _showHeader) {
        setState(() => _showHeader = false);
      } else if (notification.scrollDelta! < 0 && !_showHeader) {
        setState(() => _showHeader = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ShipmentController>();

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Kolors.kPrimary,
              Kolors.kPrimary,
              Kolors.kSecondaryLight,
            ],
          ),
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll(notification);
            return false;
          },
          child: Column(
            children: [
              // ✅ SAFE COLLAPSING HEADER
              SafeArea(
                bottom: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: _showHeader ? 56 : 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: const Center(
                      child: Text(
                        'My Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ BODY
              Expanded(
                child: _buildBody(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────── UI PARTS ─────────────────────────────

  Widget _buildBody(ShipmentController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (controller.error != null) {
      return _buildErrorState(controller.error!);
    }

    if (controller.shipments.isEmpty) {
      return _buildEmptyState();
    }

    return _buildShipmentList(controller);
  }

  // ───────────────────────────── STATES ─────────────────────────────

  Widget _buildShipmentList(ShipmentController controller) {
    return RefreshIndicator(
      color: Kolors.kPrimary,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        itemCount: controller.shipments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, index) {
          return ShipmentScheduleCard(
            shipment: controller.shipments[index],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 100,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Orders Scheduled!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
