import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/client_qr_checkin_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/global_util/services/controler/session_by_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/screens/sessions/views/session_screen.dart';

enum PaymentType { cash, card }

class ClientQrCheckinScreen extends StatefulWidget {
  final int shipmentId;

  const ClientQrCheckinScreen({super.key, required this.shipmentId});

  @override
  State<ClientQrCheckinScreen> createState() => _ClientQrCheckinScreenState();
}

class _ClientQrCheckinScreenState extends State<ClientQrCheckinScreen> {
  late SessionByShipmentController _sessionController;
  late VoidCallback _sessionListener;

  PaymentType _selectedPaymentType = PaymentType.cash;
  bool _isHandlingNavigation = false;

  @override
  void initState() {
    super.initState();

    _sessionController = context.read<SessionByShipmentController>();

    _sessionListener = () async {
      final session = _sessionController.session;

      if (!mounted || session == null || _isHandlingNavigation) return;

      _isHandlingNavigation = true;

      if (_selectedPaymentType == PaymentType.cash) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SessionScreen(session: session),
          ),
        );
        return;
      }

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const PaymentProcessingOverlayScreen(),
        ),
      );

      if (!mounted) return;

      if (completed == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SessionScreen(session: session),
          ),
        );
      } else {
        _isHandlingNavigation = false;
      }
    };

    _sessionController.addListener(_sessionListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionController.startSessionPolling(
        widget.shipmentId.toString(),
      );
    });
  }

  @override
  void dispose() {
    _sessionController.removeListener(_sessionListener);
    _sessionController.stopPolling();
    super.dispose();
  }

  void _onPaymentTypeChanged(PaymentType type) {
    if (!mounted) return;
    setState(() {
      _selectedPaymentType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ClientCheckinController()..loadCheckinToken(widget.shipmentId),
      child: ClientQrCheckinContent(
        selectedPaymentType: _selectedPaymentType,
        onPaymentTypeChanged: _onPaymentTypeChanged,
      ),
    );
  }
}

class PaymentProcessingOverlayScreen extends StatefulWidget {
  const PaymentProcessingOverlayScreen({super.key});

  @override
  State<PaymentProcessingOverlayScreen> createState() =>
      _PaymentProcessingOverlayScreenState();
}

class _PaymentProcessingOverlayScreenState
    extends State<PaymentProcessingOverlayScreen> {
  @override
  void initState() {
    super.initState();
    _simulateProcessing();
  }

  Future<void> _simulateProcessing() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.55),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black12,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
              SizedBox(height: 20),
              Text(
                'Processing Payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Please wait while we confirm the card payment.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}