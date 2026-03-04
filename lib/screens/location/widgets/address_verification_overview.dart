import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressSuccessOverlay extends StatefulWidget {
  final VoidCallback onCompleted;

  const AddressSuccessOverlay({super.key, required this.onCompleted});

  @override
  State<AddressSuccessOverlay> createState() =>
      _AddressSuccessOverlayState();
}

class _AddressSuccessOverlayState
    extends State<AddressSuccessOverlay> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    // Trigger Entry Animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Auto-dismiss logic
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
          _scale = 1.1; // Slight expand as it fades out
        });
      }
      Future.delayed(const Duration(milliseconds: 500), widget.onCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Premium blur effect
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Kolors.kPrimary.withOpacity(0.15), // Tinted brand overlay
            child: Center(
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut, // Bouncy "Pop" effect
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Animated Icon Container ---
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.greenAccent.shade700,
                        size: 80.sp,
                      ),
                    ),
                    
                    SizedBox(height: 30.h),

                    // --- Text ---
                    Text(
                      "Welcome to Plug",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    Text(
                      "Your profile is ready!",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}