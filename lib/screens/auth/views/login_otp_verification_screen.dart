import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_login_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_otp_login_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_auth_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:flutter_application_1/screens/auth/widgets/success_overlay_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginOtpVerificationScreen extends StatefulWidget {
  const LoginOtpVerificationScreen({super.key});

  @override
  State<LoginOtpVerificationScreen> createState() =>
      _LoginOtpVerificationScreenState();
}

class _LoginOtpVerificationScreenState
    extends State<LoginOtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://www.plugprovider.co.za');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        FlushbarService.error(context, 'Unable to open the website.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to open website: $e');
      }
      if (!mounted) return;
      FlushbarService.error(context, 'Unable to open the website.');
    }
  }

    void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Fallback navigation in case context.go('/otpVerification') replaced the route stack entirely
      context.go('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Colors.lightBlueAccent;

    final email =
        LoginController.instance.emailController.text.trim().toLowerCase();
    final maskedIdentifier =
        LoginController.instance.challenge?.data.verificationToken;

    return ChangeNotifierProvider<GetClientAuthController>(
      create: (_) => GetClientAuthController(),
      child: Scaffold(
        body: Consumer2<LoginOtpController, GetClientAuthController>(
          builder: (context, provider, authController, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Kolors.kPrimary,
                    accentColor,
                    Kolors.kWhite,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 35.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
      
                            // --- Top App Bar Actions ---
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                    onPressed: _handleBackNavigation,
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  SizedBox(width: 12.w),
                                    Container(
                                      width: 56.w,
                                      height: 56.h,
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      child: Image.asset(
                                        'assets/icons/plug_splash.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _openWebsite,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 6.h),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: Icon(Icons.help_outline_rounded,
                                      size: 18.sp),
                                  label: Text(
                                    "Help",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
      
                            SizedBox(height: 30.h),
      
                            // --- Header ---
                            Text(
                              "Verify it's you",
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              maskedIdentifier != null
                                  ? "Enter the code we sent to your email address"
                                  : "Enter the code we sent to complete your login",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 50.h),
      
                            // --- Form Card ---
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildOtpField(
                                    controller: _otpController,
                                    errorText: provider.fieldErrors['otp'],
                                    accentColor: accentColor,
                                  ),
                                ],
                              ),
                            ),
      
                            // --- General Error display ---
                            if (provider.error != null) ...[
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  provider.error!,
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
      
                    // --- Bottom Actions ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 35.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          provider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: accentColor,
                                  ),
                                )
                              : GradientBtn(
                                  text: "VERIFY",
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
      
                                    final success =
                                        await provider.verifyOtp(
                                      otp: _otpController.text,
                                    );
      
                                    if (!context.mounted || !success) {
                                      return;
                                    }
      
                                    SuccessOverlay.show(
                                      context,
                                      message:
                                          "Welcome back! We are preparing your profile.",
                                    );
      
                                    await context
                                        .read<GetClientAuthController>()
                                        .loadClientAuth(email);
      
                                    await Future.delayed(
                                        const Duration(seconds: 2));
      
                                    if (!context.mounted) return;
      
                                    Navigator.of(context).pop();
      
                                    final profileState = context
                                        .read<GetClientAuthController>()
                                        .clientAuth
                                        ?.profileStatus;
      
                                    LoginController.instance.clear();
                                    AuthSessionController.instance
                                        .clearOtpSession();
      
                                    if (profileState == "in-details") {
                                      context.go('/clientDetailsPatch');
                                    } else if (profileState ==
                                        "in-address") {
                                      context.go('/addaddress');
                                    } else if (profileState ==
                                        "in-email-verification") {
                                      context.go('/otpVerification');
                                    } else {
                                      context.go('/entryPoint');
                                    }
                                  },
                                  btnColor: accentColor,
                                  radius: 16.r,
                                  btnHieght: 58.h,
                                  btnWidth: double.infinity,
                                ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ReusableText(
                                text: "Didn't get a code? ",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: provider.isLoading
                                    ? null
                                    : () async {
                                        final success =
                                            await provider.resendOtp();
                                        if (context.mounted && success) {
                                          FlushbarService.success(
                                            context,
                                            'Your OTP has been successfully sent.',
                                          );
                                        }
                                      },
                                child: Text(
                                  "Resend",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpField({
    required TextEditingController controller,
    required Color accentColor,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        hintText: "000000",
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          vertical: 18.h,
          horizontal: 16.w,
        ),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : accentColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}