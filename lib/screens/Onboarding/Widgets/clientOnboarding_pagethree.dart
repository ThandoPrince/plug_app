import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreenThree extends StatelessWidget {
  const OnboardingScreenThree({super.key});

  /// Request location permission directly
  Future<void> _requestLocationPermission(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      // Permission granted, navigate to entry point
      context.go("/entryPoint");
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Location permission permanently denied. Please enable it in settings."
          ),
          action: SnackBarAction(
            label: "Settings",
            onPressed: openAppSettings,
          ),
        ),
      );
    } else {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission is required to continue."
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Kolors.kPrimary,
        shadowColor: Kolors.kPrimary,
        centerTitle: true,
        title: const Text(
          'Welcome to Plug 🔌!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kWhite],
              begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Need a cleaner, a beauty guru, or a handyman? Plug 🔌 brings services to your doorstep — fast.',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Let’s get you started on the journey!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Kolors.kDark,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              GradientBtn(
                text: "Get Started",
                onTap: () => _requestLocationPermission(context),
                btnColor: Kolors.kPrimary,
                radius: 20,
                btnHieght: 45,
                btnWidth: ScreenUtil().screenWidth - 80,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ReusableText(
                    text: "Already have an account? ",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go("/onboarding"),
                    child: ReusableText(
                      text: "Login",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
