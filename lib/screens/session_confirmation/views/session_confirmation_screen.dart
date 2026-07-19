import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/client_qr_checkin_content.dart';
import 'package:flutter_application_1/screens/sessions/views/session_screen.dart';
import 'package:provider/provider.dart';

enum PaymentType { cash, card }

class ClientQrCheckinScreen extends StatefulWidget {
  final int shipmentId;
  final GoogleShipmentRouteController googleShipmentRouteController;

  const ClientQrCheckinScreen({
    super.key,
    required this.shipmentId,
    required this.googleShipmentRouteController
  });

  @override
  State<ClientQrCheckinScreen> createState() => _ClientQrCheckinScreenState();
}

class _ClientQrCheckinScreenState extends State<ClientQrCheckinScreen> {
  PaymentType _selectedPaymentType = PaymentType.cash;

  bool _isNavigating = false;

  @override
void initState() {
  super.initState();

  widget.googleShipmentRouteController.startRealtime(widget.shipmentId);
}

  Future<void> _handleSession(SessionModel session) async {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;

    if (_selectedPaymentType == PaymentType.cash) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionScreen(session: session, googleShipmentRouteController: widget.googleShipmentRouteController,),
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
          builder: (_) => SessionScreen(session: session, googleShipmentRouteController: widget.googleShipmentRouteController,),
        ),
      );
    } else {
      _isNavigating = false;
    }
  }

  void _onPaymentTypeChanged(PaymentType type) {
    setState(() {
      _selectedPaymentType = type;
    });

    final shipmentController = context.read<ShipmentController>();

    final session = shipmentController.sessionForShipment(widget.shipmentId);

    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSession(session);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ShipmentController, SessionModel?>(
      selector: (_, controller) =>
          controller.sessionForShipment(widget.shipmentId),
      builder: (context, session, child) {
        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleSession(session);
          });
        }

        return ChangeNotifierProvider(
          create: (_) =>
              ClientCheckinController()..loadCheckinToken(widget.shipmentId),
          child: ClientQrCheckinContent(
            selectedPaymentType: _selectedPaymentType,
            onPaymentTypeChanged: _onPaymentTypeChanged,
          ),
        );
      },
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

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
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
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Processing Payment",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Please wait while we confirm the card payment.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
