import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/reset_password_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _useEmail = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ResetPasswordController>();

    final success = await controller.resetPassword(
      email: _useEmail ? _identifierController.text.trim() : null,
      mobileNumber: !_useEmail ? _identifierController.text.trim() : null,
      newPassword: _passwordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          success
              ? (controller.successMessage ?? "Password reset successfully")
              : (controller.errorMessage ?? "Failed to reset password"),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: Kolors.kPrimary,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Kolors.kOffWhite),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Reset Password",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            bottom: controller.isLoading
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(2),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Kolors.kSecondaryLight),
                    ),
                  )
                : null,
          ),
          body: Container(
                        width: double.infinity,
              height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Forgot your password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Choose your validation identifier type below to update your security credentials.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Modern Segmented Selection Control
                      LayoutBuilder(
                        builder: (context, constraints) => ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              _useEmail = index == 0;
                              _identifierController.clear();
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          selectedBorderColor: Colors.white.withOpacity(0.2),
                          selectedColor: Kolors.kPrimary,
                          fillColor: Colors.white,
                          color: Colors.white.withOpacity(0.8),
                          constraints: BoxConstraints.expand(
                            width: (constraints.maxWidth - 4) / 2,
                            height: 48,
                          ),
                          isSelected: [_useEmail, !_useEmail],
                          children: const [
                            Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
                            Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Fields Block
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: _useEmail ? TextInputType.emailAddress : TextInputType.phone,
                        style: const TextStyle(color: Kolors.kDark, fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration(
                          hint: _useEmail ? "Email Address" : "Mobile Number",
                          prefixIcon: _useEmail ? Icons.mail_outline : Icons.phone_android_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _useEmail ? "Email is required" : "Mobile number is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Kolors.kDark, fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration(
                          hint: "New Password",
                          prefixIcon: Icons.lock_open_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Kolors.kDark.withOpacity(0.6),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Kolors.kDark, fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration(
                          hint: "Confirm Password",
                          prefixIcon: Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Kolors.kDark.withOpacity(0.6),
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Action Submission Control Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Kolors.kPrimary,
                            foregroundColor: Kolors.kPrimary,
                            elevation: 0,
                            disabledBackgroundColor: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Kolors.kPrimary,
                                  ),
                                )
                              : const Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Kolors.kOffWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: Kolors.kDark.withOpacity(0.5), fontWeight: FontWeight.normal),
      prefixIcon: Icon(prefixIcon, color: Kolors.kDark.withOpacity(0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      errorStyle: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
    );
  }
}