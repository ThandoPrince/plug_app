import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class OfflinePage extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflinePage({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.lightBlueAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Soft off-white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Styled Icon Container with a subtle glow effect
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Ionicons.wifi_outline,
                  size: 80,
                  color: themeColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),

              // Headline Status
              const Text(
                "No Internet Connection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E24),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Supporting Text
              Text(
                "Oops! It seems like you are not connected to the internet. Please check your network settings and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Interactive Action Button
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Ionicons.refresh_outline, size: 18),
                label: const Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(160, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}