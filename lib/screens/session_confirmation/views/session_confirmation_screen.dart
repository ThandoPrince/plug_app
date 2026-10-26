import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/client_payment_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/session_by_shipment_ctrl.dart';
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
    required this.googleShipmentRouteController,
  });

  @override
  State<ClientQrCheckinScreen> createState() => _ClientQrCheckinScreenState();
}

class _ClientQrCheckinScreenState extends State<ClientQrCheckinScreen> {
  PaymentType _selectedPaymentType = PaymentType.cash;

  bool _isNavigating = false;

  // Owned by this screen (not provided globally) for two reasons:
  //  1. its polling timer stops as soon as the screen closes, and
  //  2. this State can listen to it and decide when to move on.
  late final ClientPaymentController _payCtrl;

  @override
  void initState() {
    super.initState();

    _payCtrl = ClientPaymentController()..addListener(_onPaymentChanged);

    widget.googleShipmentRouteController.startRealtime(widget.shipmentId);
  }

  @override
  void dispose() {
    _payCtrl.removeListener(_onPaymentChanged);
    _payCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation rule: the ONLY thing that opens the live session screen is the
  // server saying the session is `in_session`. A session that exists but is
  // still `awaiting_payment` keeps the client here, where Pay now lives.
  // That can be reported by either source below; whichever is first wins.
  // ---------------------------------------------------------------------------

  /// Source 1: the payment poll / select-method / verify responses.
  void _onPaymentChanged() {
    if (!mounted || _isNavigating) return;
    if (_payCtrl.payment?.sessionStatus != 'in_session') return;

    WidgetsBinding.instance.addPostFrameCallback((_) => _openLiveSession());
  }

  SessionModel? _liveSessionFromShipmentCtrl() {
    final s = context
        .read<ShipmentController>()
        .sessionForShipment(widget.shipmentId);
    return s?.sessionStatus == 'in_session' ? s : null;
  }

  Future<SessionModel?> _fetchLiveSession() async {
    try {
      final ctrl = context.read<SessionByShipmentController>();
      await ctrl.fetchSession(widget.shipmentId.toString());
      final s = ctrl.session;
      return s?.sessionStatus == 'in_session' ? s : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openLiveSession() async {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    // The server just said the session is live, but our copy of it may be a moment behind.
    SessionModel? session;
    for (var attempt = 0; attempt < 4 && mounted; attempt++) {
      session = _liveSessionFromShipmentCtrl() ?? await _fetchLiveSession();
      if (session != null) break;
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;

    if (session == null) {
      // Couldn't load it. Allow the next status update to try again.
      _isNavigating = false;
      return;
    }

    final liveSession = session;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          session: liveSession,
          googleShipmentRouteController: widget.googleShipmentRouteController,
        ),
      ),
    );
  }

  /// The server has already saved the choice by the time this runs (see _onSelectMethod
  /// in the content widget), so this only updates what the screen shows.
  void _onPaymentTypeChanged(PaymentType type) {
    setState(() {
      _selectedPaymentType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Source 2: the session as the shipment controller sees it (socket-driven).
    // Selecting the status string means the screen reacts even if the session
    // object is updated in place.
    return Selector<ShipmentController, String?>(
      selector: (_, controller) =>
          controller.sessionForShipment(widget.shipmentId)?.sessionStatus,
      builder: (context, sessionStatus, child) {
        if (sessionStatus == 'in_session') {
          WidgetsBinding.instance.addPostFrameCallback((_) => _openLiveSession());
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  ClientCheckinController()..loadCheckinToken(widget.shipmentId),
            ),
            ChangeNotifierProvider<ClientPaymentController>.value(
              value: _payCtrl,
            ),
          ],
          child: ClientQrCheckinContent(
            selectedPaymentType: _selectedPaymentType,
            onPaymentTypeChanged: _onPaymentTypeChanged,
          ),
        );
      },
    );
  }
}