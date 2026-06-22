import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/update_order_service_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EditOrderScreen extends StatefulWidget {
  final OrderServiceModel booking;

  const EditOrderScreen({
    super.key,
    required this.booking,
  });

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.booking.title ?? '');
    _notesController = TextEditingController(text: widget.booking.notes ?? '');
    _selectedDate = widget.booking.requestedDate;

    if (widget.booking.requestedDateTime != null) {
      _selectedTime = TimeOfDay(
        hour: widget.booking.requestedDateTime!.hour,
        minute: widget.booking.requestedDateTime!.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      setState(() => _selectedTime = result);
    }
  }

  Future<void> _submit(UpdateOrderServiceController controller) async {
    if (_titleController.text.trim().isEmpty) {
      FlushbarService.warning(context, "Please enter a title");
      return;
    }
    if (_notesController.text.trim().isEmpty) {
      FlushbarService.warning(context, "Please enter notes");
      return;
    }
    if (_selectedDate == null) {
      FlushbarService.warning(context, "Please select a date");
      return;
    }
    if (_selectedTime == null) {
      FlushbarService.warning(context, "Please select a time");
      return;
    }

    final bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (bookingDateTime.isBefore(DateTime.now().add(const Duration(hours: 1)))) {
      FlushbarService.warning(context, "Booking must be at least 1 hour from now");
      return;
    }

    final success = await controller.updateOrder(
  orderId: widget.booking.orderId!,
  title: _titleController.text.trim(),
  notes: _notesController.text.trim(),
  requestedDate: _selectedDate!.toIso8601String().split('T')[0],
  requestedTime:
      "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00",
);

if (!mounted) return;

if (success) {

  final pendingCtrl =
      context.read<ClientPendingOrdersController>();

  await Future.wait([
    pendingCtrl.fetchPendingOrders(),
  ]);

  FlushbarService.success(
    context,
    "Order updated successfully",
  );

  await Future.delayed(
    const Duration(milliseconds: 500),
  );

  Navigator.pop(context, true);
}else {
      FlushbarService.error(context, controller.errorMessage ?? "Failed to update order");
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Kolors.kPrimary ?? Colors.blue.shade900;
    final secondaryColor = Kolors.kSecondaryLight ?? Colors.blue.shade300;

    return ChangeNotifierProvider(
      create: (_) => UpdateOrderServiceController(),
      child: Consumer<UpdateOrderServiceController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: primaryColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Edit Order Details",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor.withOpacity(0.95)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Service Info",
                                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Kolors.kDark),
                                    ),
                                    SizedBox(height: 16.h),
                                    _buildTextField(
                                      controller: _titleController,
                                      label: "Order Title",
                                      icon: Icons.title,
                                    ),
                                    SizedBox(height: 16.h),
                                    _buildTextField(
                                      controller: _notesController,
                                      label: "Special Instructions / Notes",
                                      icon: Icons.description,
                                      maxLines: 4,
                                    ),
                                    SizedBox(height: 24.h),
                                    Text(
                                      "Schedule",
                                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Kolors.kDark),
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildSelectorTile(
                                      icon: Icons.calendar_month,
                                      title: _selectedDate == null
                                          ? "Select Date"
                                          : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                                      onTap: _pickDate,
                                    ),
                                    const Divider(height: 1, color: Colors.black12),
                                    _buildSelectorTile(
                                      icon: Icons.access_time,
                                      title: _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                                      onTap: _pickTime,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 24.h, bottom: 16.h),
                              child: GradientBtn(
                                text: controller.isLoading ? "Saving changes..." : "Save Changes",
                                btnColor: primaryColor,
                                btnWidth: double.infinity,
                                btnHieght: 52.h,
                                radius: 14,
                                onTap: controller.isLoading ? null : () => _submit(controller),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Kolors.kPrimary, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        alignLabelWithHint: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Kolors.kPrimary ?? Colors.blue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Kolors.kPrimary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }
}