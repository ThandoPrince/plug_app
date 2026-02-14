import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/OnboardingSliderTwo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreenTwo extends StatelessWidget {
  const OnboardingScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color backgroundColor1 = Kolors.kPrimary;
    const Color backgroundColor2 = Kolors.kWhite;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor1, backgroundColor1, backgroundColor2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),

                // --- Headline focused on Action & Visibility ---
                Text(
                  'Book, Relax, and\nTrack in Real-Time.',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // --- Visual Hero Section ---
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: const Onboardingslidertwo(), 
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // --- Updated Trust Tag ---
                const Text(
                  'TRANSPARENT & TRUSTED',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Kolors.kDark,
                  ),
                ),

                SizedBox(height: 12.h),

                // --- Body Text including Tracking ---
                Text(
                  'Browse vetted specialists and track your provider’s arrival to your doorstep in real-time. Reliability you can see.',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),
                
                SizedBox(height: 120.h), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}