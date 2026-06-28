import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';

import 'package:flutter_application_1/global_util/services/controler/cancel_shipment_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_reshedule_controler.dart';
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
  
  
late ShipmentCancelController cancelCtrl;
late ShipmentRescheduleController rescheduleCtrl;



  bool _showHeader = true;

 @override
void initState() {
  super.initState();
  

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context
        .read<ShipmentController>()
        .fetchShipmentsByClientEmail();
  });
  
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  cancelCtrl = context.read<ShipmentCancelController>();
  rescheduleCtrl = context.read<ShipmentRescheduleController>();
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight], // Deep brand gradient
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

  



void showShipmentCancelDialog({
  required BuildContext context,
  required ShipmentCancelController cancelCtrl,
  required ShipmentController listCtrl,
  required int shipmentId,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final controller = Provider.of<ShipmentCancelController>(
        dialogContext,
        listen: false,
      );

      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Cancel Shipment",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to cancel this shipment? This action cannot be undone.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientBtn(
                text: "YES, CANCEL",
                btnColor: Colors.red,
                textColor: Colors.white,
                btnHieght: 50,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  await controller.cancelShipment(shipmentId);

                  if (!context.mounted) return;

                  if (controller.success) {
                    await listCtrl.refresh();

                    FlushbarService.success(
  context,
  "Shipment cancelled successfully.",
);;
                  } else {
                    FlushbarService.error(
  context,
  controller.errorMessage ?? "Failed to cancel shipment.",
);
                  }
                },
              ),

              const SizedBox(height: 10),

              GradientBtn(
                text: "NO, KEEP IT",
                btnColor: Kolors.kPrimary,
                textColor: Kolors.kOffWhite,
                btnHieght: 50,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void showShipmentRescheduleDialog({
  required BuildContext context,
  required ShipmentRescheduleController rescheduleCtrl,
  required ShipmentController listCtrl,
  required int shipmentId,
}) {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final controller = Provider.of<ShipmentRescheduleController>(
        dialogContext,
        listen: false,
      );

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Reschedule Shipment",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DATE PICKER
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TIME PICKER
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedTime == null
                          ? "Select Time"
                          : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientBtn(
                    text: "RESCHEDULE",
                    btnColor: Colors.blue,
                    textColor: Colors.white,
                    btnHieght: 50,
                    btnWidth: double.infinity,
                    radius: 12,
                    onTap: () async {
                      if (selectedDate == null || selectedTime == null) {
                        FlushbarService.warning(
  context,
  "Please select both a date and time.",
);
                        return;
                      }

                      final formattedDate =
                          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                      final formattedTime =
                          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

                      Navigator.of(dialogContext).pop();

                     final success = await controller.rescheduleShipment(
  shipmentId: shipmentId,
  newDate: formattedDate,
  newTime: formattedTime,
);

if (!context.mounted) return;

if (success) {
  await listCtrl.refresh();

  FlushbarService.success(
    context,
    "Shipment rescheduled successfully.",
  );
  await listCtrl.refresh();
} else {
  FlushbarService.error(
    context,
    controller.errorMessage ?? "Failed to reschedule shipment.",
  );
}
                    },
                  ),

                  const SizedBox(height: 10),

                  GradientBtn(
                    text: "CANCEL",
                    btnColor: Colors.grey.shade300,
                    textColor: Colors.black,
                    btnHieght: 50,
                    btnWidth: double.infinity,
                    radius: 12,
                    onTap: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}



  void _showShipmentActions(BuildContext context, int shipmentId) {
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
              // 🔘 drag handle
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

              // ───────── RESCHEDULE ─────────
              _ActionTile(
                icon: Icons.schedule,
                label: "Reschedule",
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);

                  showShipmentRescheduleDialog(
                    context: context,
                    rescheduleCtrl:
                        context.read<ShipmentRescheduleController>(),
                    listCtrl: context.read<ShipmentController>(),
                    shipmentId: shipmentId,
                  );
                },
              ),

              const SizedBox(height: 12),

              // ───────── CANCEL ─────────
              _ActionTile(
                icon: Icons.cancel,
                label: "Cancel Shipment",
                color: Colors.red,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);

                  showShipmentCancelDialog(
                    context: context,
                    cancelCtrl:
                        context.read<ShipmentCancelController>(),
                    listCtrl: context.read<ShipmentController>(),
                    shipmentId: shipmentId,
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
          return GestureDetector(
            onLongPress: () {
    _showShipmentActions(context, controller.shipments[index].shipmentId);
  },
            child: ShipmentScheduleCard(
              shipmentController: controller,
              shipment: controller.shipments[index],
            ),
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