import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class NegotiationAcceptedView extends StatelessWidget {
  final VoidCallback onGoToSchedule;

  const NegotiationAcceptedView({
    super.key,
    required this.onGoToSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Kolors.kPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Booking Accepted!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "The provider has accepted this negotiation. "
              "Please check the Scheduled tab for your booking details.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onGoToSchedule,
                child: const Text(
                  "Go to Scheduled Tab",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}