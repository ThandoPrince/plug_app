import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/session_confirmation/widget/client_qr_checkin_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/global_util/services/controler/session_by_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/screens/sessions/views/session_screen.dart';

class ClientQrCheckinScreen extends StatefulWidget {
  final int shipmentId;

  const ClientQrCheckinScreen({super.key, required this.shipmentId});

  @override
  State<ClientQrCheckinScreen> createState() => _ClientQrCheckinScreenState();
}

class _ClientQrCheckinScreenState extends State<ClientQrCheckinScreen> {
  late SessionByShipmentController _sessionController;
  late VoidCallback _sessionListener;

  @override
  void initState() {
    super.initState();

    _sessionController = context.read<SessionByShipmentController>();

    // Define listener ONCE
    _sessionListener = () {
      final session = _sessionController.session;

      if (!mounted || session == null) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionScreen(session: session),
        ),
      );
    };

    _sessionController.addListener(_sessionListener);

    // Only start polling after first frame
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ClientCheckinController()..loadCheckinToken(widget.shipmentId),
      child: const ClientQrCheckinContent(),
    );
  }
}
