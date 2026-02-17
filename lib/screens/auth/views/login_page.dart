import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_login_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:go_router/go_router.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Kolors.kPrimary;

    return ChangeNotifierProvider<LoginController>.value(
      value: LoginController.instance,
      child: Consumer<LoginController>(
        builder: (context, controller, _) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Kolors.kPrimary, Kolors.kPrimary, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 35.w),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: 80.h),

                            // ---- Header ----
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            const Text(
                              "Login to continue booking services",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 60.h),

                            // ---- Form Card ----
                            _buildFormCard(controller),

                            // ---- General Error ----
                            if (controller.generalError != null)
                              _buildGeneralError(controller.generalError!),
                          ],
                        ),
                      ),
                    ),

                    // ---- Bottom Button ----
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 35.w, vertical: 20.h),
                      child: controller.isLoading
                          ? const CircularProgressIndicator(
                              color: primaryColor)
                          : GradientBtn(
                              text: "LOGIN",
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final success =
                                    await controller.login();
                                if (success && mounted) {
                                  context.go('/entryPoint');
                                }
                              },
                              btnColor: primaryColor,
                              btnHieght: 58.h,
                              btnWidth: double.infinity,
                              radius: 16,
                            ),
                    ),

                    _buildSignupSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard(LoginController controller) {
    return Container(
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
          _buildEmailField(controller),
          SizedBox(height: 16.h),
          _buildPasswordField(controller),
        ],
      ),
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField(LoginController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: "Email Address",
        errorText: controller.emailError,
        prefixIcon:
            Icon(Icons.email_outlined, color: Kolors.kPrimary, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.grey.shade200),
        focusedBorder:
            _inputBorder(color: Kolors.kPrimary, width: 1.5),
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField(LoginController controller) {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: "Password",
        errorText: controller.passwordError,
        prefixIcon:
            Icon(Icons.lock_outline, color: Kolors.kPrimary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: Kolors.kPrimary,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.grey.shade200),
        focusedBorder:
            _inputBorder(color: Kolors.kPrimary, width: 1.5),
      ),
    );
  }

  // ============================================================
  // ERROR BOX
  // ============================================================

  Widget _buildGeneralError(String message) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SIGNUP SECTION
  // ============================================================

  Widget _buildSignupSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style:
              TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
        TextButton(
          onPressed: () => context.go("/authCreation"),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
              color: Kolors.kBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT BORDER
  // ============================================================

  OutlineInputBorder _inputBorder(
      {Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          BorderSide(color: color ?? Colors.transparent, width: width),
    );
  }
}
