import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/global_util/services/controler/client_otp_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
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
    const Color primaryColor = Kolors.kPrimary;

    return Scaffold(
      body: Consumer<ClientOtpController>(
        builder: (context, provider, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
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
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.h),

                          // --- Top Navigation Row ---
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
                                    width: 44.w,
                                    height: 44.h,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.help_outline_rounded,
                                    size: 18),
                                label: const Text(
                                  "Help",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 30.h),

                          // --- Header ---
                          Text(
                            "Verify your email",
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Enter the code we sent to your registered email address",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
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
                              borderRadius: BorderRadius.circular(24),
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
                                ),
                              ],
                            ),
                          ),

                          // --- Non-field / general error display ---
                          if (provider.error != null) ...[
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        provider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              )
                            : GradientBtn(
                                text: "VERIFY",
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  final success = await provider.verifyOtp(
                                    otp: _otpController.text,
                                  );

                                  if (context.mounted && success) {
                                    context.go('/clientDetailsPatch');
                                  }
                                },
                                btnColor: primaryColor,
                                radius: 16,
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
                                        FlushbarService.success(context,
                                            "A new code has been sent.");
                                      }
                                    },
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.sp,
                                  color: Kolors.kBlue,
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
    );
  }

  Widget _buildOtpField({
    required TextEditingController controller,
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
        hintStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: errorText != null ? Colors.red : Kolors.kPrimary,
              width: 1.5),
        ),
      ),
    );
  }
}
