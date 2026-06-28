import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class ConfirmServiceButton extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmServiceButton({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Kolors.kPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onConfirm,
        child: const Text(
          "Confirm Arrival",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Kolors.kOffWhite),
        ),
      ),
    );
  }
}
