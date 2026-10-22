import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/shimmers/shipment_list_skeleton.dart';
import 'package:flutter_application_1/global_util/services/widgets/common_error_state.dart';
import 'package:flutter_application_1/screens/schedule/widgets/shipment_action_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_1/screens/order_details_/views/order_details_screen.dart';
import 'package:flutter_application_1/screens/schedule/widgets/shipment_card.dart';

class ScheduledShipmentsScreen extends StatefulWidget {
  const ScheduledShipmentsScreen({super.key});

  @override
  State<ScheduledShipmentsScreen> createState() =>
      _ScheduledShipmentsScreenState();
}

class _ScheduledShipmentsScreenState extends State<ScheduledShipmentsScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedStatus = "All";
  bool _showHeader = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch moved to EntryPoint._prefetchAllTabData()
  }

  static const List<String> _statuses = [
  "All",
  "Pending",
  "In Transit",
  "Delivered",
  "In Session",
  "Rescheduled",
];

  Future<void> _onRefresh() async {
  await context.read<ShipmentController>().fetchShipmentsByClientEmail(forceRefresh: true);
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

  bool _matchesSelectedStatus(Shipment shipment) {
  if (_selectedStatus == "All") {
    return true;
  }

  final shipmentStatus = shipment.shipmentStatus.toLowerCase();

  if (_selectedStatus == "Delivered") {
    return shipmentStatus == "arrived" ||
        shipmentStatus == "delivered";
  }

  return shipmentStatus ==
      _selectedStatus.toLowerCase().replaceAll(" ", "_");
}

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    final controller = context.watch<ShipmentController>();

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll(notification);
            return false;
          },
          child: Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: _showHeader ? 56 : 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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

              // Filter Chips
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final status = _statuses[index];
                    final selected = _selectedStatus == status;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(.25),
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected) ...[
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Kolors.kPrimary,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              status,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected ? Kolors.kPrimary : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Body
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
      return const ShipmentListSkeleton();
    }

    if (controller.error != null) {
      return CommonErrorState(
        onRefresh: _onRefresh,
        title: "Unable to load shipments",
        message: "Pull down to try again.",
        icon: Icons.local_shipping_outlined,
      );
    }

   final filteredShipments = controller.shipments
    .where(_matchesSelectedStatus)
    .toList();

    if (filteredShipments.isEmpty) {
      return _buildEmptyState();
    }

    return _buildShipmentList(controller);
  }

  void _showShipmentActions(BuildContext context, Shipment shipment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Shipment Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _ActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: "View Booking Details",
                  color: Kolors.kPrimary,
                  onTap: () {
                    Navigator.pop(context);
                    final orderId = shipment.serviceOrdered?.orderId;
                    if (orderId == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(orderId: orderId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.schedule,
                  label: "Reschedule",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    showShipmentRescheduleDialog(
                      context: context,
                      shipmentId: shipment.shipmentId,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.cancel,
                  label: "Cancel Shipment",
                  color: Colors.red,
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    showShipmentCancelDialog(
                      context: context,
                      shipmentId: shipment.shipmentId,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────── STATES ─────────────────────────────

  Widget _buildShipmentList(ShipmentController controller) {
    final shipments = controller.shipments
    .where(_matchesSelectedStatus)
    .toList();

    return RefreshIndicator(
      color: Kolors.kPrimary,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        itemCount: shipments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, index) {
          final shipment = shipments[index];

          return GestureDetector(
            onLongPress: () {
              _showShipmentActions(context, shipment);
            },
            child: ShipmentScheduleCard(
              shipmentController: controller,
              shipment: shipment,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
  return RefreshIndicator(
    color: Kolors.kPrimary,       // Spinner/progress color
    backgroundColor: Colors.white, // Background circle color
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
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.08)
                : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red : Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}