import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_login_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_auth_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:flutter_application_1/screens/auth/widgets/success_overlay_widget.dart';
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
  bool _isPhoneInput = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to instantly style or adjust for phone/email differences
    LoginController.instance.emailController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    LoginController.instance.emailController.removeListener(_onInputChanged);
    LoginController.instance.clear();
    super.dispose();
  }

  void _onInputChanged() {
    final text = LoginController.instance.emailController.text.trim();
    
    if (text.isEmpty) {
      if (_isPhoneInput) setState(() => _isPhoneInput = false);
      return;
    }

    // Check if user is starting to type a phone number
    final isDigits = RegExp(r'^[0-9+]+$').hasMatch(text);

    if (isDigits && !_isPhoneInput) {
      setState(() => _isPhoneInput = true);
    } else if (!isDigits && _isPhoneInput) {
      setState(() => _isPhoneInput = false);
    }

    // Automatically enforce SA +27 formatting variations dynamically
    if (isDigits) {
      if (text.startsWith('0') && text.length > 1) {
        final formatted = '+27${text.substring(1)}';
        _updateControllerText(formatted);
      } else if (!text.startsWith('+') && !text.startsWith('27') && text.isNotEmpty) {
        final formatted = '+27$text';
        _updateControllerText(formatted);
      } else if (text.startsWith('27') && text.length > 2) {
        final formatted = '+$text';
        _updateControllerText(formatted);
      }
    }
  }

  void _updateControllerText(String formattedText) {
    final controller = LoginController.instance.emailController;
    controller.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formattedText.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Kolors.kPrimary;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginController>.value(
          value: LoginController.instance,
        ),
        ChangeNotifierProvider<GetClientAuthController>(
          create: (_) => GetClientAuthController(),
        ),
      ],
      child: Consumer2<LoginController, GetClientAuthController>(
        builder: (context, loginController, authController, _) {
          return DoubleBackToExit(
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight], // Deep brand gradient
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
                              _buildFormCard(loginController),

                              // ---- General Error ----
                              if (loginController.generalError != null)
                                _buildGeneralError(
                                    loginController.generalError!),

                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                                  child: TextButton(
                                    onPressed: () => context.push('/reset_password'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      foregroundColor: Colors.white.withOpacity(0.2),
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.sp,
                                        color: Kolors.kBlue,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ---- Bottom Button ----
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 35.w, vertical: 20.h),
                        child: loginController.isLoading
                            ? const CircularProgressIndicator(
                                color: primaryColor)
                            : GradientBtn(
                                text: "LOGIN",
                                onTap: () async {
                                  FocusScope.of(context).unfocus();

                                  final success = await loginController.login();

                                  if (success) {
                                    final email = loginController
                                        .emailController.text
                                        .trim().toLowerCase();

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

                                    if (!mounted) return;

                                    Navigator.of(context).pop(); // dismiss overlay

                                    final profileState = context
                                        .read<GetClientAuthController>()
                                        .clientAuth
                                        ?.profileStatus;

                                    if (profileState == "in-details") {
                                      context.go(
                                          '/clientDetailsPatch?email=$email');
                                    } else if (profileState == "in-address") {
                                      context.go('/addaddress?email=$email');
                                    } else if (profileState == "completed") {
                                      context.go('/entryPoint');
                                    } else {
                                      context.go('/entryPoint');
                                    }
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
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildEmailField(LoginController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress, // Better for showing mixed text/keyboard layouts
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: "Email Address or Mobile Number",
        errorText: controller.emailError,
        prefixIcon: Icon(
          _isPhoneInput ? Icons.phone_android_outlined : Icons.email_outlined, 
          color: Kolors.kPrimary, 
          size: 20,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.grey.shade200),
        focusedBorder: _inputBorder(color: Kolors.kPrimary, width: 1.5),
      ),
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return TextFormField(
      controller: controller.passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: "Password",
        errorText: controller.passwordError,
        prefixIcon: Icon(Icons.lock_outline, color: Kolors.kPrimary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Kolors.kPrimary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: _inputBorder(),
        enabledBorder: _inputBorder(color: Colors.grey.shade200),
        focusedBorder: _inputBorder(color: Kolors.kPrimary, width: 1.5),
      ),
    );
  }

  Widget _buildGeneralError(String message) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

  Widget _buildSignupSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
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

  OutlineInputBorder _inputBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color ?? Colors.transparent, width: width),
    );
  }
}