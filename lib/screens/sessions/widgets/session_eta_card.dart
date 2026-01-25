import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/screens/sessions/widgets/ui_status_helper.dart';
import 'card_decoration.dart';

class SessionEtaCard extends StatefulWidget {
  final ClientSessionLocationPingController controller;
  final SessionModel session;

  const SessionEtaCard({
    super.key,
    required this.controller,
    required this.session,
  });

  @override
  State<SessionEtaCard> createState() => _SessionEtaCardState();
}

class _SessionEtaCardState extends State<SessionEtaCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Initialize with backend duration if available
    _setElapsedFromBackend();

    // Start a timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });

    // Listen to controller changes
    widget.controller.addListener(_onControllerUpdate);
  }

  void _setElapsedFromBackend() {
    final backendSeconds = widget.controller.latestPing?.session?.durationSeconds ?? 0;
    setState(() {
      _elapsed = Duration(seconds: backendSeconds.toInt());
    });
  }

  void _onControllerUpdate() {
    // If backend sends a new duration, reset _elapsed
    final backendSeconds = widget.controller.latestPing?.session?.durationSeconds;
    if (backendSeconds != null) {
      setState(() {
        _elapsed = Duration(seconds: backendSeconds.toInt());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusUI = getSessionStatusUI(
      sessionStatus: widget.session.sessionStatus,
      isInsideGeofence: widget.controller.isInsideGeofence,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(
            Icons.access_time_rounded,
            _formatDuration(_elapsed),
            'Duration',
            Kolors.kPrimary,
          ),
          VerticalDivider(color: Colors.grey.shade200, thickness: 1),
          _buildMetric(
            statusUI.icon,
            statusUI.label,
            'Status',
            statusUI.color,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Widget _buildMetric(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
