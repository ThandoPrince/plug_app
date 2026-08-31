import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmServiceButton extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmServiceButton({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Kolors.kPrimary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onConfirm,
        child: const Text(
          "Confirm Arrival",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Kolors.kOffWhite,
          ),
        ),
      ),
    );
  }
}