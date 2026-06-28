import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SensitiveContainer extends StatelessWidget {
  const SensitiveContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConnectivityBuilder(
      builder: (context, isConnected, status) {
        final bool connected = isConnected ?? true;

        return Stack(
          children: [
            child,
            if (!connected)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StatusBanner(
                  message: "You are offline. Features may be limited.",
                  icon: Ionicons.wifi_outline,
                  actionLabel: "RETRY",
                ),
              ),
          ],
        );
      },
    );
  }
}

class StatusBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;

  const StatusBanner({
    super.key,
    required this.message,
    required this.icon,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically fetch the primary brand color or fallback to lightBlueAccent
    final themeColor = Theme.of(context).primaryColor == Colors.blue 
        ? Colors.lightBlueAccent 
        : Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      // Ambient decoration with solid background and sharp definition shadow
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // High-visibility status indicator circle
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeColor, size: 18),
              ),
              const SizedBox(width: 12),
              
              // Text payload field
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1C1B1F),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              
              // Optional clean text action link
              if (actionLabel != null) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    // Trigger manual connection diagnostic re-evaluation loop
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}