import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/reset_password_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  const ResetPasswordConfirmScreen({super.key});

  @override
  State<ResetPasswordConfirmScreen> createState() =>
      _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState
    extends State<ResetPasswordConfirmScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _confirmReset() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ResetPasswordController>();

    final success = await controller.confirmReset(
      otp: _otpController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(success
            ? "Password reset successfully"
            : (controller.errorMessage ?? "Failed to reset password")),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      // Clear sensitive fields before leaving the flow entirely.
      _passwordController.clear();
      _confirmPasswordController.clear();
      _otpController.clear();
      context.go('/login');
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
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: Kolors.kOffWhite),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Enter Verification Code",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            bottom: controller.isLoading
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(2),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Kolors.kSecondaryLight),
                    ),
                  )
                : null,
          ),
          body: Container(
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
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Almost done",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Enter the code we sent you and choose a new password.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Kolors.kDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                hint: "Verification Code",
                prefixIcon: Icons.pin_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Verification code is required";
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: Kolors.kDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                hint: "New Password",
                prefixIcon: Icons.lock_open_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Kolors.kDark.withOpacity(0.6),
                  ),
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return "Password must be at least 8 characters";
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return "Include at least one uppercase letter";
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return "Include at least one lowercase letter";
                }
                if (!RegExp(r'\d').hasMatch(value)) {
                  return "Include at least one digit";
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(
                color: Kolors.kDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: _buildInputDecoration(
                hint: "Confirm Password",
                prefixIcon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Kolors.kDark.withOpacity(0.6),
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword =
                        !_obscureConfirmPassword,
                  ),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),

            // Push the button to the bottom
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    controller.isLoading ? null : _confirmReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Kolors.kPrimary,
                  elevation: 0,
                  disabledBackgroundColor:
                      Colors.white.withOpacity(0.3),
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

            const SizedBox(height: 8),
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

  InputDecoration _buildInputDecoration(
      {required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(
          color: Kolors.kDark.withOpacity(0.5), fontWeight: FontWeight.normal),
      prefixIcon: Icon(prefixIcon, color: Kolors.kDark.withOpacity(0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      errorStyle: const TextStyle(
          color: Color(0xFFB71C1C), fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
