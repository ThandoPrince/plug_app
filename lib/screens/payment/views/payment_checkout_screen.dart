// // Client app. Needs `webview_flutter` (4.x) in pubspec.yaml.
// //
// // Closing this screen proves nothing about payment. The result is whatever the backend says,
// // so while the page is open we ask the backend (which asks Paystack) every few seconds, and the
// // screen closes itself the moment the payment is settled.
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/common/utils/kcolors.dart';
// import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
// import 'package:flutter_application_1/global_util/services/controler/client_payment_controller.dart';
// import 'package:flutter_application_1/global_util/services/models/order_service_models/payment_model.dart';
// import 'package:provider/provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// /// Opens checkout for the current payment. Safe to call from the auto-launch hook or the
// /// "Pay now" button.
// Future<void> launchPaystackCheckout(BuildContext context) async {
//   final ctrl = context.read<ClientPaymentController>();
//   if (ctrl.checkoutOpen || ctrl.isInitiating) return;

//   ctrl.markAutoLaunched();
//   ctrl.checkoutOpen = true;

//   try {
//     final payment = await ctrl.initiateCheckout();
//     final url = payment?.checkout?.authorizationUrl ?? '';

//     if (url.isEmpty) {
//       if (context.mounted) {
//         FlushbarService.error(context, ctrl.error ?? 'Could not start payment.');
//       }
//       return;
//     }
//     if (!context.mounted) return;

//     // The checkout page is a separate route, so it cannot see the controller that lives
//     // inside the check-in screen. Hand it over explicitly.
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (_) => PaystackCheckoutScreen(url: url, controller: ctrl),
//       ),
//     );

//     // Covers the case where the user closed the page themselves right after paying.
//     await ctrl.pollUntilSettled();
//   } finally {
//     ctrl.checkoutOpen = false;
//   }
// }

// class PaystackCheckoutScreen extends StatefulWidget {
//   final String url;
//   final ClientPaymentController controller;

//   const PaystackCheckoutScreen({
//     super.key,
//     required this.url,
//     required this.controller,
//   });

//   @override
//   State<PaystackCheckoutScreen> createState() => _PaystackCheckoutScreenState();
// }

// class _PaystackCheckoutScreenState extends State<PaystackCheckoutScreen> {
//   late final WebViewController _web;
//   Timer? _verifyTimer;
//   int _progress = 0;
//   bool _closing = false;

//   @override
//   void initState() {
//     super.initState();

//     widget.controller.addListener(_onPaymentChanged);

//     // Ask the backend to check with Paystack while the page is open.
//     _verifyTimer = Timer.periodic(
//       const Duration(seconds: 4),
//       (_) => widget.controller.verifyNow(),
//     );

//     _web = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (p) {
//             if (mounted) setState(() => _progress = p);
//           },
//           // 3-D Secure pages redirect to bank domains, so don't allowlist hosts;
//           // just refuse anything that isn't https.
//           onNavigationRequest: (req) {
//             final uri = Uri.tryParse(req.url);
//             if (uri == null || uri.scheme != 'https') {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   @override
//   void dispose() {
//     _verifyTimer?.cancel();
//     widget.controller.removeListener(_onPaymentChanged);
//     super.dispose();
//   }

//   /// Close as soon as the payment is settled, either way. The check-in screen behind this one
//   /// then shows the result (and moves on to the session if it succeeded).
//   void _onPaymentChanged() {
//     if (_closing) return;

//     final p = widget.controller.payment;
//     if (p == null) return;

//     if (p.isPaid || p.status == PaymentStatus.failed) {
//       _closing = true;
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && Navigator.of(context).canPop()) {
//           Navigator.of(context).pop();
//         }
//       });
//     }
//   }

//   Future<bool> _confirmClose() async {
//     final close = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Leave payment?'),
//         content: const Text(
//           "If you've already paid, we'll confirm it automatically. "
//           'Otherwise you can come back and tap Pay now.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(false),
//             child: const Text('Stay'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(true),
//             child: const Text('Leave'),
//           ),
//         ],
//       ),
//     );
//     return close ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _confirmClose,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Secure payment'),
//           backgroundColor: Kolors.kPrimary,
//           foregroundColor: Colors.white,
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () async {
//               if (await _confirmClose() && mounted) Navigator.of(context).pop();
//             },
//           ),
//           bottom: _progress < 100
//               ? PreferredSize(
//                   preferredSize: const Size.fromHeight(3),
//                   child: LinearProgressIndicator(
//                     value: _progress / 100,
//                     minHeight: 3,
//                     backgroundColor: Colors.transparent,
//                     color: Colors.white,
//                   ),
//                 )
//               : null,
//         ),
//         body: SafeArea(child: WebViewWidget(controller: _web)),
//       ),
//     );
//   }
// }