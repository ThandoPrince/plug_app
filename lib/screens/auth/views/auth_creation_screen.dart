import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/global_util/services/controler/client_auth_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthCreationScreen extends StatefulWidget {
  const AuthCreationScreen({super.key});

  @override
  State<AuthCreationScreen> createState() => _AuthCreationScreenState();
}

class _AuthCreationScreenState extends State<AuthCreationScreen> {
  bool _isPasswordVisible = false;

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://www.plugprovider.co.za/');

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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;

    return DoubleBackToExit(
      child: Scaffold(
        // ONE Single Consumer wraps everything so State updates propagate everywhere
        body: Consumer<ClientAuthProvider>(
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
                        padding: EdgeInsets.symmetric(horizontal: 35.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
  width: 56,
  height: 56,
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.transparent, // Fully transparent
    borderRadius: BorderRadius.circular(14),
  ),
  child: Image.asset(
    'assets/icons/plug_splash.png',
    fit: BoxFit.contain,
  ),
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
                              "Join us at Plug",
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            const Text(
                              "Create an account to start booking services",
                              style: TextStyle(
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
                                  _buildTextField(
                                    controller: provider.emailController,
                                    hint: "Email Address",
                                    icon: Icons.email_outlined,
                                    errorText: provider.fieldErrors['email'],
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildTextField(
                                    controller: provider.mobileController,
                                    hint: "Mobile Number (072XXX)",
                                    icon: Icons.phone_android_outlined,
                                    type: TextInputType.phone,
                                    errorText: provider.fieldErrors['mobile'],
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildTextField(
                                    controller: provider.passwordController,
                                    hint: "Password",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    isPasswordVisible: _isPasswordVisible,
                                    onTogglePassword: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    errorText: provider.fieldErrors['password'],
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildTextField(
                                    controller:
                                        provider.confirmPasswordController,
                                    hint: "Confirm Password",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    isPasswordVisible: _isPasswordVisible,
                                    onTogglePassword: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    errorText:
                                        provider.fieldErrors['confirmPassword'],
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

                    // --- Bottom Actions (Now safely reads from same consumer) ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 35.w, vertical: 20.h),
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
                                  text: "CREATE ACCOUNT",
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    final success = await provider.register();

                                    if (context.mounted && success) {
                                      context.go('/otpVerification');
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
                                text: "Already part of the community? ",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go("/login"),
                                child: Text(
                                  "Login",
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? errorText,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isPasswordVisible : false,
      keyboardType: type,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: Kolors.kPrimary, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        errorText: errorText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
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
