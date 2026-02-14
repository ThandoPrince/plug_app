import 'package:flutter/material.dart';

class SessionStatusUI {
  final String label;
  final Color color;
  final IconData icon;

  const SessionStatusUI({
    required this.label,
    required this.color,
    required this.icon,
  });
}

SessionStatusUI getSessionStatusUI({
  required String? sessionStatus,
  required bool isInsideGeofence,
}) {
  if (!isInsideGeofence) {
    return const SessionStatusUI(
      label: 'Outside Area',
      color: Colors.red,
      icon: Icons.warning_amber_rounded,
    );
  }

  switch (sessionStatus?.toLowerCase()) {
    case 'pending':
      return const SessionStatusUI(
        label: 'Pending',
        color: Colors.orange,
        icon: Icons.hourglass_empty,
      );
    case 'in_session':
      return const SessionStatusUI(
        label: 'In Session',
        color: Colors.green,
        icon: Icons.play_circle_fill,
      );
    case 'completed':
      return const SessionStatusUI(
        label: 'Completed',
        color: Colors.purple  ,
        icon: Icons.check_circle,
      );
    default:
      return const SessionStatusUI(
        label: 'Unknown',
        color: Colors.grey,
        icon: Icons.help_outline,
      );
  }
}
