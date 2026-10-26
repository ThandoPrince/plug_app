// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/common/utils/kcolors.dart';
// import 'package:flutter_application_1/common/widgets/custom_button.dart';
// import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
// import 'package:flutter_application_1/global_util/services/controler/client_payment_controller.dart';
// import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
// import 'package:flutter_application_1/global_util/services/controler/update_final_price_controller.dart';
// import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';
// import 'package:flutter_application_1/screens/payment/views/payment_checkout_screen.dart';
// import 'package:flutter_application_1/screens/payment/widgets/payment_status_banner.dart';
// import 'package:flutter_application_1/screens/schedule/widgets/go_to_schedule_helper.dart';
// import 'package:flutter_application_1/screens/session_confirmation/views/session_confirmation_screen.dart';
// import 'package:flutter_application_1/screens/session_confirmation/widget/detail_row.dart';
// import 'package:flutter_application_1/screens/session_confirmation/widget/ticket_divider.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';



// class ClientQrCheckinContent extends StatefulWidget {
//   final PaymentType selectedPaymentType;
//   final ValueChanged<PaymentType> onPaymentTypeChanged;

//   const ClientQrCheckinContent({
//     super.key,
//     required this.selectedPaymentType,
//     required this.onPaymentTypeChanged,
//   });

//   @override
//   State<ClientQrCheckinContent> createState() => _ClientQrCheckinContentState();
// }

// class _ClientQrCheckinContentState extends State<ClientQrCheckinContent> {
//   double? _localFinalPriceOverride;
//   bool _paymentBootstrapped = false;

//   PaymentMethod _toMethod(PaymentType type) =>
//       type == PaymentType.card ? PaymentMethod.card : PaymentMethod.cash;

//   /// Runs once, as soon as the check-in token (and so the shipment) is available.
//   Future<void> _bootstrapPayment(ClientCheckinController controller) async {
//     if (_paymentBootstrapped) return;

//     // NOTE: confirm the field name on your shipment model (shipmentId?).
//     final shipmentId = controller.token?.shipment?.shipmentId;
//     if (shipmentId == null) return;
//     _paymentBootstrapped = true;

//     final payCtrl = context.read<ClientPaymentController>();
//     final payment = await payCtrl.bootstrap(
//       shipmentId: shipmentId,
//       defaultMethod: _toMethod(widget.selectedPaymentType),
//     );
//     if (!mounted) return;

//     if (payment == null) {
//       FlushbarService.error(
//         context,
//         payCtrl.error ?? 'Could not load payment details.',
//       );
//       return;
//     }

//     // Reopened screen: reflect what was saved earlier.
//     final saved = payment.isCard ? PaymentType.card : PaymentType.cash;
//     if (saved != widget.selectedPaymentType) {
//       widget.onPaymentTypeChanged(saved);
//     }
//   }

//   /// Saves the choice on the server first; the UI only switches once that succeeds.
//   Future<void> _onSelectMethod(
//     ClientCheckinController controller,
//     PaymentType type,
//   ) async {
//     if (type == widget.selectedPaymentType) return;

//     final shipmentId = controller.token?.shipment?.shipmentId;
//     if (shipmentId == null) return;

//     final payCtrl = context.read<ClientPaymentController>();
//     if (payCtrl.isSelecting) return;

//     final ok = await payCtrl.selectMethod(
//       shipmentId: shipmentId,
//       method: _toMethod(type),
//     );
//     if (!mounted) return;

//     if (ok) {
//       widget.onPaymentTypeChanged(type);
//     } else {
//       FlushbarService.error(
//         context,
//         payCtrl.error ?? 'Could not update payment type.',
//       );
//     }
//   }

//   String get _paymentTypeLabel {
//     switch (widget.selectedPaymentType) {
//       case PaymentType.cash:
//         return 'Cash';
//       case PaymentType.card:
//         return 'Card';
//     }
//   }

//   bool _interactionEnabled(ClientCheckinController controller) {
//   if (controller.token == null) return false;

//   return !controller.isExpired;
// }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         goToSchedule(context);
//         return false;
//       },
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => goToSchedule(context),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           title: const Text(
//             "Service Check-in",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         body: Consumer<ClientCheckinController>(
//           builder: (context, controller, _) {
//             return Container(
//                 width: double.infinity,
//                 height: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//           colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//               ),
//               child: SafeArea(
//                 child: _buildContent(context, controller),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(
//     BuildContext context,
//     ClientCheckinController controller,
//   ) {
//     if (controller.isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.white),
//       );
//     }

//     if (controller.error != null) {
//       return _buildErrorState(controller.error!);
//     }

//     if (controller.token == null) {
//       return _buildErrorState("No check-in token available");
//     }

//     final order = controller.token!.shipment?.serviceOrdered;
    
//     final int? orderId = order?.orderId;

//     final double backendFinalPrice =
//         double.tryParse(order?.finalPrice?.toString() ?? '') ?? 0.00;

//     final double displayedPrice = _localFinalPriceOverride ?? backendFinalPrice;

//     final payCtrl = context.watch<ClientPaymentController>();

//     if (!_paymentBootstrapped) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) _bootstrapPayment(controller);
//       });
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       child: Column(
//         children: [
//           const SizedBox(height: 20),

//       if (!_interactionEnabled(controller))
//   Container(
//     width: double.infinity,
//     margin: const EdgeInsets.only(bottom: 20),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.red.shade50,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Colors.red.shade200),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Icon(Icons.lock_outline, color: Colors.red),
//             SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 "This check-in session has expired.",
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: controller.isRefreshing
//                 ? null
//                 : () => controller.refreshToken(),
//             icon: controller.isRefreshing
//                 ? const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Icon(Icons.refresh, size: 18),
//             label: Text(controller.isRefreshing ? "Refreshing..." : "Refresh Token"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Kolors.kPrimary,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   ),

//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(28),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(height: 30),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Kolors.kSecondaryLight,
//                       width: 2,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: QrImageView(
//                     data: controller.qrData,
//                     size: 220,
//                     version: QrVersions.auto,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   "SCAN TO CHECK-IN",
//                   style: TextStyle(
//                     letterSpacing: 2,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 14,
//                     color: Kolors.kPrimary,
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20),
//                   child: TicketDivider(),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
//                   child: Column(
//                     children: [
//                       const PaymentStatusBanner(),

//                       // Opens Paystack checkout once, automatically, when the provider scans.
//                       Consumer<ClientPaymentController>(
//                         builder: (context, pc, _) {
//                           if (pc.canAutoLaunch) {
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               if (!context.mounted) return;
//                               if (context.read<ClientPaymentController>().canAutoLaunch) {
//                                 launchPaystackCheckout(context);
//                               }
//                             });
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       ),

//                       _EditablePriceRow(
//                         label: "Amount Due",
//                         value: "R ${displayedPrice.toStringAsFixed(2)}",
//                         icon: Icons.payments_outlined,
//                         enabled: orderId != null &&
//                             _interactionEnabled(controller) &&
//                             !payCtrl.priceLocked,
//                         onEdit: orderId == null
//                             ? null
//                             : () => _editFinalPrice(
//                                   context: context,
//                                   orderId: orderId,
//                                   currentPrice: displayedPrice,
//                                 ),
//                       ),
//                       const SizedBox(height: 16),
//                       AbsorbPointer(
//   absorbing: !_interactionEnabled(controller),
//   child: Opacity(
//     opacity: _interactionEnabled(controller) ? 1.0 : 0.45,
//     child: _PaymentTypeSelector(
//       selectedPaymentType: widget.selectedPaymentType,
//       onChanged: (type) => _onSelectMethod(controller, type),
//     ),
//   ),
// ),
//                       const SizedBox(height: 16),
//                       DetailRow(
//                         label: "Payment Type",
//                         value: _paymentTypeLabel,
//                         icon: widget.selectedPaymentType == PaymentType.cash
//                             ? Icons.money
//                             : Icons.credit_card,
//                       ),
//                       const SizedBox(height: 16),
//                       DetailRow(
//                         label: "Expires In",
//                         value: controller.formattedRemaining,
//                         icon: Icons.timer_outlined,
//                       ),
//                       const SizedBox(height: 12),
//                       Consumer<PatchOrderFinalPriceController>(
//   builder: (context, patchCtrl, _) {
//     if (patchCtrl.isLoading) {
//       return const Padding(
//         padding: EdgeInsets.only(top: 8),
//         child: LinearProgressIndicator(),
//       );
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!context.mounted) return;

//       if (patchCtrl.error != null) {
//         FlushbarService.error(
//           context,
//           patchCtrl.error!,
//         );

//         patchCtrl.clearState();
//       } else if (patchCtrl.successMessage != null) {
//         FlushbarService.success(
//           context,
//           patchCtrl.successMessage!,
//         );

//         patchCtrl.clearState();
//       }
//     });

//     return const SizedBox.shrink();
//   },
// ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _editFinalPrice({
//     required BuildContext context,
//     required int orderId,
//     required double currentPrice,
//   }) async {

//     if (!mounted) return;

//   final checkinController = context.read<ClientCheckinController>();

//   if (checkinController.isExpired) {
//     FlushbarService.error(context,
//       "This QR code has expired. Please go back or refresh.",
//     );
//     return;
//   }

//   if (context.read<ClientPaymentController>().priceLocked) {
//     FlushbarService.error(
//       context,
//       "The price can't be changed once payment has started.",
//     );
//     return;
//   }

//     final patchController = context.read<PatchOrderFinalPriceController>();

//     final newPrice = await showDialog<double>(
//       context: context,
//       builder: (dialogContext) {
//         return _EditFinalPriceDialog(initialPrice: currentPrice);
//       },
//     );

//     if (newPrice == null) return;
//     if (newPrice == currentPrice) return;

//     final proceed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//   backgroundColor: Colors.white,
//   surfaceTintColor: Colors.transparent,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(20),
//   ),
//   title: const Text(
//     "Confirm Price Update",
//     textAlign: TextAlign.center,
//     style: TextStyle(
//       fontSize: 22,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   content: RichText(
//   textAlign: TextAlign.center,
//   text: TextSpan(
//     style: TextStyle(
//       color: Colors.black87,
//       fontSize: 14.sp,
//       height: 1.5,
//     ),
//     children: [
//       const TextSpan(
//         text: 'Proceed with updating the final price to\n\n',
//       ),
//       TextSpan(
//         text: 'R ${newPrice.toStringAsFixed(2)}',
//         style: TextStyle(
//           color: Kolors.kPrimary,
//           fontWeight: FontWeight.bold,
//           fontSize: 18.sp,
//         ),
//       ),
//       TextSpan(
//         text: '\n\nPayment Type: $_paymentTypeLabel',
//       ),
//     ],
//   ),
// ),
//   actions: [
//     Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GradientBtn(
//           text: "YES, UPDATE",
//           btnColor: Kolors.kPrimary,
//           textColor: Kolors.kWhite,
//           btnHieght: 50.h,
//           btnWidth: double.infinity,
//           radius: 12,
//           onTap: () {
//             Navigator.of(dialogContext).pop(true);
//           },
//         ),
//         SizedBox(height: 10.h),
//         GradientBtn(
//           text: "CANCEL",
//           btnColor: Colors.grey.shade300,
//           textColor: Colors.black,
//           btnHieght: 50.h,
//           btnWidth: double.infinity,
//           radius: 12,
//           onTap: () {
//             Navigator.of(dialogContext).pop(false);
//           },
//         ),
//       ],
//     ),
//   ],
// );
//       },
//     );

//     if (proceed != true) return;
//     if (!mounted) return;

//     patchController.clearState();

//     final success = await patchController.patchFinalPrice(
//       orderId: orderId,
//       finalPrice: newPrice,
//       isNegotiated: true,
//     );

//     if (!mounted) return;

//     if (success) {
//       setState(() {
//         _localFinalPriceOverride = newPrice;
//       });

      
//     }
//   }

//   Widget _buildErrorState(String message) {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(24),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.red,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EditFinalPriceDialog extends StatefulWidget {
//   final double initialPrice;

//   const _EditFinalPriceDialog({
//     required this.initialPrice,
//   });

//   @override
//   State<_EditFinalPriceDialog> createState() => _EditFinalPriceDialogState();
// }

// class _EditFinalPriceDialogState extends State<_EditFinalPriceDialog> {
//   late final TextEditingController _textController;

  

//   @override
// void initState() {
//   super.initState();

//   _textController = TextEditingController(
    
//     text: widget.initialPrice.toStringAsFixed(2),
//   );

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _textController.selection = TextSelection(
//       baseOffset: 0,
//       extentOffset: _textController.text.length,
//     );
//   });
// }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     final parsed = double.tryParse(
//       _textController.text.trim().replaceAll(',', '.'),
//     );

//     if (parsed == null || parsed < 0 || parsed == 0) {
//       FlushbarService.error(
//         context,
//         'Please enter a valid non-negative number.',
//       );
//       return;
//     }

//     Navigator.of(context).pop(parsed);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//   backgroundColor: Colors.white,
//   surfaceTintColor: Colors.transparent,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(20),
//   ),
//   title: const Text(
//     "Edit Final Price",
//     textAlign: TextAlign.center,
//     style: TextStyle(
//       fontSize: 22,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   content: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       const Text(
//         "Enter the final agreed price.",
//         textAlign: TextAlign.center,
//       ),
//       SizedBox(height: 16.h),
//       TextField(
//         controller: _textController,
//         keyboardType: const TextInputType.numberWithOptions(
//           decimal: true,
//         ),
//         autofocus: true,
//         decoration: InputDecoration(
//           labelText: "Final Price",
//           prefixText: "R ",
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: Colors.grey.shade400,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(
//               color: Kolors.kPrimary,
//               width: 2,
//             ),
//           ),
//         ),
//         onSubmitted: (_) => _submit(),
//       ),
//     ],
//   ),
//   actions: [
//     Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GradientBtn(
//           text: "CONTINUE",
//           btnColor: Kolors.kPrimary,
//           textColor: Kolors.kWhite,
//           btnHieght: 50.h,
//           btnWidth: double.infinity,
//           radius: 12,
//           onTap: _submit,
//         ),
//         SizedBox(height: 10.h),
//         GradientBtn(
//           text: "CANCEL",
//           btnColor: Colors.grey.shade300,
//           textColor: Colors.black,
//           btnHieght: 50.h,
//           btnWidth: double.infinity,
//           radius: 12,
//           onTap: () => Navigator.of(context).pop(),
//         ),
//       ],
//     ),
//   ],
// );
//   }
// }

// class _PaymentTypeSelector extends StatelessWidget {
//   final PaymentType selectedPaymentType;
//   final ValueChanged<PaymentType> onChanged;

//   const _PaymentTypeSelector({
//     required this.selectedPaymentType,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Icon(Icons.account_balance_wallet_outlined, color: Kolors.kPrimary),
//             SizedBox(width: 8),
//             Text(
//               'Payment Type',
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black87,
//                 fontSize: 15,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _PaymentTypeCard(
//                 title: 'Cash',
//                 icon: Icons.money,
//                 isSelected: selectedPaymentType == PaymentType.cash,
//                 onTap: () => onChanged(PaymentType.cash),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _PaymentTypeCard(
//                 title: 'Card',
//                 icon: Icons.credit_card,
//                 isSelected: selectedPaymentType == PaymentType.card,
//                 onTap: () => onChanged(PaymentType.card),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _PaymentTypeCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _PaymentTypeCard({
//     required this.title,
//     required this.icon,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final borderColor = isSelected ? Kolors.kPrimary : Colors.grey.shade300;
//     final bgColor = isSelected
//         ? Kolors.kPrimary.withOpacity(0.08)
//         : Colors.grey.shade50;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: borderColor,
//             width: isSelected ? 2 : 1.2,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Kolors.kPrimary : Colors.black54,
//               size: 26,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: isSelected ? Kolors.kPrimary : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EditablePriceRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final bool enabled;
//   final VoidCallback? onEdit;

//   const _EditablePriceRow({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.enabled,
//     required this.onEdit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: enabled ? onEdit : null,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         child: Row(
//           children: [
//             Icon(icon, color: Kolors.kPrimary),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: Kolors.kPrimary,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Opacity(
//   opacity: enabled ? 1 : 0.4,
//   child: Icon(
//     Icons.edit_outlined,
//     size: 18,
//     color: enabled ? Kolors.kPrimary : Colors.grey,
//   ),
// ),
//           ],
//         ),
//       ),
//     );
//   }
// }

















import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/client_payment_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/update_final_price_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';
import 'package:flutter_application_1/screens/payment/widgets/payment_status_banner.dart';
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
  bool _paymentBootstrapped = false;

  PaymentMethod _toMethod(PaymentType type) =>
      type == PaymentType.card ? PaymentMethod.card : PaymentMethod.cash;

  /// Runs once, as soon as the check-in token (and so the shipment) is available.
  Future<void> _bootstrapPayment(ClientCheckinController controller) async {
    if (_paymentBootstrapped) return;

    // NOTE: confirm the field name on your shipment model (shipmentId?).
    final shipmentId = controller.token?.shipment?.shipmentId;
    if (shipmentId == null) return;
    _paymentBootstrapped = true;

    final payCtrl = context.read<ClientPaymentController>();
    final payment = await payCtrl.bootstrap(
      shipmentId: shipmentId,
      defaultMethod: _toMethod(widget.selectedPaymentType),
    );
    if (!mounted) return;

    if (payment == null) {
      FlushbarService.error(
        context,
        payCtrl.error ?? 'Could not load payment details.',
      );
      return;
    }

    // Card is "coming soon". If an earlier card choice is still saved on the server,
    // switch it back to cash so the provider's scan can start the session.
    if (payment.isCard && !payment.isPaid) {
      final switched = await payCtrl.selectMethod(
        shipmentId: shipmentId,
        method: PaymentMethod.cash,
      );
      if (!mounted) return;
      if (switched) widget.onPaymentTypeChanged(PaymentType.cash);
      return;
    }

    // Reopened screen: reflect what was saved earlier.
    final saved = payment.isCard ? PaymentType.card : PaymentType.cash;
    if (saved != widget.selectedPaymentType) {
      widget.onPaymentTypeChanged(saved);
    }
  }

  /// Saves the choice on the server first; the UI only switches once that succeeds.
  Future<void> _onSelectMethod(
    ClientCheckinController controller,
    PaymentType type,
  ) async {
    if (type == widget.selectedPaymentType) return;

    // Hackathon scope: card payments are not live yet.
    if (type == PaymentType.card) {
      FlushbarService.error(
        context,
        'Card payments are coming soon. Please pay your provider in cash for now.',
      );
      return;
    }

    final shipmentId = controller.token?.shipment?.shipmentId;
    if (shipmentId == null) return;

    final payCtrl = context.read<ClientPaymentController>();
    if (payCtrl.isSelecting) return;

    final ok = await payCtrl.selectMethod(
      shipmentId: shipmentId,
      method: _toMethod(type),
    );
    if (!mounted) return;

    if (ok) {
      widget.onPaymentTypeChanged(type);
    } else {
      FlushbarService.error(
        context,
        payCtrl.error ?? 'Could not update payment type.',
      );
    }
  }

  String get _paymentTypeLabel {
    switch (widget.selectedPaymentType) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.card:
        return 'Card';
    }
  }

  bool _interactionEnabled(ClientCheckinController controller) {
  if (controller.token == null) return false;

  return !controller.isExpired;
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
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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

    final payCtrl = context.watch<ClientPaymentController>();

    if (!_paymentBootstrapped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _bootstrapPayment(controller);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

      if (!_interactionEnabled(controller))
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "This check-in session has expired.",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isRefreshing
                ? null
                : () => controller.refreshToken(),
            icon: controller.isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(controller.isRefreshing ? "Refreshing..." : "Refresh Token"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Kolors.kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    ),
  ),

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
                      const PaymentStatusBanner(),

                      _EditablePriceRow(
                        label: "Amount Due",
                        value: "R ${displayedPrice.toStringAsFixed(2)}",
                        icon: Icons.payments_outlined,
                        enabled: orderId != null &&
                            _interactionEnabled(controller) &&
                            !payCtrl.priceLocked,
                        onEdit: orderId == null
                            ? null
                            : () => _editFinalPrice(
                                  context: context,
                                  orderId: orderId,
                                  currentPrice: displayedPrice,
                                ),
                      ),
                      const SizedBox(height: 16),
                      AbsorbPointer(
  absorbing: !_interactionEnabled(controller),
  child: Opacity(
    opacity: _interactionEnabled(controller) ? 1.0 : 0.45,
    child: _PaymentTypeSelector(
      selectedPaymentType: widget.selectedPaymentType,
      onChanged: (type) => _onSelectMethod(controller, type),
    ),
  ),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      if (patchCtrl.error != null) {
        FlushbarService.error(
          context,
          patchCtrl.error!,
        );

        patchCtrl.clearState();
      } else if (patchCtrl.successMessage != null) {
        FlushbarService.success(
          context,
          patchCtrl.successMessage!,
        );

        patchCtrl.clearState();
      }
    });

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

    if (!mounted) return;

  final checkinController = context.read<ClientCheckinController>();

  if (checkinController.isExpired) {
    FlushbarService.error(context,
      "This QR code has expired. Please go back or refresh.",
    );
    return;
  }

  if (context.read<ClientPaymentController>().priceLocked) {
    FlushbarService.error(
      context,
      "The price can't be changed once payment has started.",
    );
    return;
  }

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

    if (parsed == null || parsed < 0 || parsed == 0) {
      FlushbarService.error(
        context,
        'Please enter a valid non-negative number.',
      );
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
            Opacity(
  opacity: enabled ? 1 : 0.4,
  child: Icon(
    Icons.edit_outlined,
    size: 18,
    color: enabled ? Kolors.kPrimary : Colors.grey,
  ),
),
          ],
        ),
      ),
    );
  }
}