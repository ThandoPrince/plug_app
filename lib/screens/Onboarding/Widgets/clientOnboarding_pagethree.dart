import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreenThree extends StatefulWidget {
  const OnboardingScreenThree({super.key});

  @override
  State<OnboardingScreenThree> createState() => _OnboardingScreenThreeState();
}

class _OnboardingScreenThreeState extends State<OnboardingScreenThree> {
  bool _isAgreed = false;

  Future<void> _handleGetStarted() async {
    if (!_isAgreed) {
      _showErrorSnackBar("Please accept the Terms of Use to continue.");
      return;
    }
    
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      context.go("/authCreation");
    } else {
      _showPermissionSnackBar();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(20.w),
      ),
    );
  }

  void _showPermissionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location access helps us find pros near you.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color backgroundColor1 = Kolors.kPrimary;
    const Color backgroundColor2 = Kolors.kWhite;
    const Color textColor = Colors.blue;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ backgroundColor1, backgroundColor1,backgroundColor2, ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
         
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
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

                // --- Center Section: Visual Cue ---
                Container(
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded, // Swapped to a 'Launch' icon for the final screen
                    size: 80,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                // --- Bottom Section: Actions & Legal ---
                // This now sits comfortably at the bottom where indicators used to be
                Column(
                  children: [
                    // Legal Checkbox
                    Row(
                      children: [
                        SizedBox(
                          height: 24.w,
                          width: 24.w,
                          child: Checkbox(
                            value: _isAgreed,
                            activeColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            onChanged: (val) => setState(() => _isAgreed = val ?? false),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 12.sp, color: Colors.black54, height: 1.4),
                              children: [
                                const TextSpan(text: "By continuing, you agree to our "),
                                TextSpan(
                                  text: "Terms",
                                  style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: " & "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25.h),

                    // Primary Get Started Button
                    GradientBtn(
                      text: "GET STARTED",
                      onTap: _handleGetStarted,
                      // Subtle visual cue: button is less vibrant if not agreed
                      btnColor: _isAgreed ? primaryColor : primaryColor.withOpacity(0.5),
                      radius: 16,
                      btnHieght: 58, 
                      btnWidth: double.infinity,
                    ),

                    SizedBox(height: 10.h),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ReusableText(
                          text: "Already have an account? ",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black45,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go("/login"),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Small padding to prevent the "Login" button from touching the very bottom edge
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