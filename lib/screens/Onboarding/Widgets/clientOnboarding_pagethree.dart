
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/services/storage.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreenThree extends StatefulWidget {
  const OnboardingScreenThree({super.key});

  @override
  State<OnboardingScreenThree> createState() =>
      _OnboardingScreenThreeState();
}

class _OnboardingScreenThreeState extends State<OnboardingScreenThree> {
  bool _isAgreed = false;

  Future<void> _handleGetStarted() async {
    if (!_isAgreed) {
      _showErrorSnackBar(
        "Please accept the Terms of Use to continue.",
      );
      return;
    }

    final status = await Permission.locationWhenInUse.request();

    if (!mounted) return;

    if (status.isGranted) {
      // Mark onboarding as completed ONLY after
      // the user successfully clicks GET STARTED
      // and grants the required permission.
      Storage().setBool('firstOpen', true);

      if (!mounted) return;

      context.go("/authCreation");
    } else {
      _showPermissionSnackBar();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        duration: const Duration(seconds: 4),
        margin: EdgeInsets.only(
          top: 20.h,
          bottom: MediaQuery.of(context).size.height - 160.h,
          left: 20.w,
          right: 20.w,
        ),
      ),
    );
  }

  void _showPermissionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "Location access helps us find pros near you.",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2C2C),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140.h,
          left: 25.w,
          right: 25.w,
        ),
        action: SnackBarAction(
          label: "SETTINGS",
          textColor: Kolors.kPrimary,
          onPressed: () async {
            final opened = await openAppSettings();

            if (!opened) {
              debugPrint("Could not open settings.");
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color textColor = Colors.blue;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Kolors.kPrimary,
              Kolors.kPrimary,
              Kolors.kWhite,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 35.w,
              vertical: 20.h,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                Text(
                  'Join the\nPlug Community.',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24.w,
                          width: 24.w,
                          child: Checkbox(
                            value: _isAgreed,
                            activeColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onChanged: (val) {
                              setState(
                                () => _isAgreed = val ?? false,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: "By continuing, you agree to our ",
                                ),
                                TextSpan(
                                  text: "Terms",
                                  style: const TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.push("/terms"),
                                ),
                                const TextSpan(text: " & "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: const TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.push("/privacy"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25.h),

                    GradientBtn(
                      text: "GET STARTED",
                      onTap: _handleGetStarted,
                      btnColor: _isAgreed
                          ? primaryColor
                          : primaryColor.withOpacity(0.5),
                      radius: 16,
                      btnHieght: 58,
                      btnWidth: double.infinity,
                    ),

                    SizedBox(height: 10.h),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
