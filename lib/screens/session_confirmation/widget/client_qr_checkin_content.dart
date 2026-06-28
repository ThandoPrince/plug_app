import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/update_final_price_controller.dart';
import 'package:flutter_application_1/screens/schedule/widgets/go_to_schedule_helper.dart';
import 'package:flutter_application_1/screens/session_confirmation/views/session_confirmation_screen.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/detail_row.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/ticket_divider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClientQrCheckinContent extends StatefulWidget {
  final PaymentType selectedPaymentType;
  final ValueChanged<PaymentType> onPaymentTypeChanged;

  const ClientQrCheckinContent({
    super.key,
    required this.selectedPaymentType,
    required this.onPaymentTypeChanged,
  });

  @override
  State<ClientQrCheckinContent> createState() => _ClientQrCheckinContentState();
}

class _ClientQrCheckinContentState extends State<ClientQrCheckinContent> {
  double? _localFinalPriceOverride;

  String get _paymentTypeLabel {
    switch (widget.selectedPaymentType) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.card:
        return 'Card';
    }
  }

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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight], // Deep brand gradient
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

  Widget _buildContent(
    BuildContext context,
    ClientCheckinController controller,
  ) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (controller.error != null) {
      return _buildErrorState(controller.error!);
    }

    if (controller.token == null) {
      return _buildErrorState("No check-in token available");
    }

    final order = controller.token!.shipment?.serviceOrdered;
    final int? orderId = order?.orderId;

    final double backendFinalPrice =
        double.tryParse(order?.finalPrice?.toString() ?? '') ?? 0.00;

    final double displayedPrice = _localFinalPriceOverride ?? backendFinalPrice;

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
                      color: Kolors.kSecondaryLight,
                      width: 2,
                    ),
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
                      _EditablePriceRow(
                        label: "Amount Due",
                        value: "R ${displayedPrice.toStringAsFixed(2)}",
                        icon: Icons.payments_outlined,
                        enabled: orderId != null,
                        onEdit: orderId == null
                            ? null
                            : () => _editFinalPrice(
                                  context: context,
                                  orderId: orderId,
                                  currentPrice: displayedPrice,
                                ),
                      ),
                      const SizedBox(height: 16),
                      _PaymentTypeSelector(
                        selectedPaymentType: widget.selectedPaymentType,
                        onChanged: widget.onPaymentTypeChanged,
                      ),
                      const SizedBox(height: 16),
                      DetailRow(
                        label: "Payment Type",
                        value: _paymentTypeLabel,
                        icon: widget.selectedPaymentType == PaymentType.cash
                            ? Icons.money
                            : Icons.credit_card,
                      ),
                      const SizedBox(height: 16),
                      DetailRow(
                        label: "Expires In",
                        value: controller.formattedRemaining,
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(height: 12),
                      Consumer<PatchOrderFinalPriceController>(
                        builder: (context, patchCtrl, _) {
                          if (patchCtrl.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: LinearProgressIndicator(),
                            );
                          }

                          if (patchCtrl.error != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                patchCtrl.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          if (patchCtrl.successMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                patchCtrl.successMessage!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
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

  Future<void> _editFinalPrice({
    required BuildContext context,
    required int orderId,
    required double currentPrice,
  }) async {
    final patchController = context.read<PatchOrderFinalPriceController>();

    final newPrice = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return _EditFinalPriceDialog(initialPrice: currentPrice);
      },
    );

    if (newPrice == null) return;
    if (newPrice == currentPrice) return;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  title: const Text(
    "Confirm Price Update",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  content: RichText(
  textAlign: TextAlign.center,
  text: TextSpan(
    style: TextStyle(
      color: Colors.black87,
      fontSize: 14.sp,
      height: 1.5,
    ),
    children: [
      const TextSpan(
        text: 'Proceed with updating the final price to\n\n',
      ),
      TextSpan(
        text: 'R ${newPrice.toStringAsFixed(2)}',
        style: TextStyle(
          color: Kolors.kPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      TextSpan(
        text: '\n\nPayment Type: $_paymentTypeLabel',
      ),
    ],
  ),
),
  actions: [
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GradientBtn(
          text: "YES, UPDATE",
          btnColor: Kolors.kPrimary,
          textColor: Kolors.kWhite,
          btnHieght: 50.h,
          btnWidth: double.infinity,
          radius: 12,
          onTap: () {
            Navigator.of(dialogContext).pop(true);
          },
        ),
        SizedBox(height: 10.h),
        GradientBtn(
          text: "CANCEL",
          btnColor: Colors.grey.shade300,
          textColor: Colors.black,
          btnHieght: 50.h,
          btnWidth: double.infinity,
          radius: 12,
          onTap: () {
            Navigator.of(dialogContext).pop(false);
          },
        ),
      ],
    ),
  ],
);
      },
    );

    if (proceed != true) return;
    if (!mounted) return;

    patchController.clearState();

    final success = await patchController.patchFinalPrice(
      orderId: orderId,
      finalPrice: newPrice,
      isNegotiated: true,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _localFinalPriceOverride = newPrice;
      });

      FlushbarHelper.createSuccess(
        message:
            'Final price updated to R ${newPrice.toStringAsFixed(2)}. Payment type: $_paymentTypeLabel.',
      ).show(context);
    }
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EditFinalPriceDialog extends StatefulWidget {
  final double initialPrice;

  const _EditFinalPriceDialog({
    required this.initialPrice,
  });

  @override
  State<_EditFinalPriceDialog> createState() => _EditFinalPriceDialogState();
}

class _EditFinalPriceDialogState extends State<_EditFinalPriceDialog> {
  late final TextEditingController _textController;

  @override
void initState() {
  super.initState();

  _textController = TextEditingController(
    text: widget.initialPrice.toStringAsFixed(2),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );
  });
}

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = double.tryParse(
      _textController.text.trim().replaceAll(',', '.'),
    );

    if (parsed == null || parsed < 0) {
      FlushbarHelper.createError(
        message: 'Please enter a valid non-negative number.',
      ).show(context);
      return;
    }

    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  title: const Text(
    "Edit Final Price",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        "Enter the final agreed price.",
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 16.h),
      TextField(
        controller: _textController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        autofocus: true,
        decoration: InputDecoration(
          labelText: "Final Price",
          prefixText: "R ",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Kolors.kPrimary,
              width: 2,
            ),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
    ],
  ),
  actions: [
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GradientBtn(
          text: "CONTINUE",
          btnColor: Kolors.kPrimary,
          textColor: Kolors.kWhite,
          btnHieght: 50.h,
          btnWidth: double.infinity,
          radius: 12,
          onTap: _submit,
        ),
        SizedBox(height: 10.h),
        GradientBtn(
          text: "CANCEL",
          btnColor: Colors.grey.shade300,
          textColor: Colors.black,
          btnHieght: 50.h,
          btnWidth: double.infinity,
          radius: 12,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  ],
);
  }
}

class _PaymentTypeSelector extends StatelessWidget {
  final PaymentType selectedPaymentType;
  final ValueChanged<PaymentType> onChanged;

  const _PaymentTypeSelector({
    required this.selectedPaymentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Kolors.kPrimary),
            SizedBox(width: 8),
            Text(
              'Payment Type',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaymentTypeCard(
                title: 'Cash',
                icon: Icons.money,
                isSelected: selectedPaymentType == PaymentType.cash,
                onTap: () => onChanged(PaymentType.cash),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentTypeCard(
                title: 'Card',
                icon: Icons.credit_card,
                isSelected: selectedPaymentType == PaymentType.card,
                onTap: () => onChanged(PaymentType.card),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Kolors.kPrimary : Colors.grey.shade300;
    final bgColor = isSelected
        ? Kolors.kPrimary.withOpacity(0.08)
        : Colors.grey.shade50;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Kolors.kPrimary : Colors.black54,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Kolors.kPrimary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditablePriceRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onEdit;

  const _EditablePriceRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.enabled,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onEdit : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Kolors.kPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Kolors.kPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: enabled ? Kolors.kPrimary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}