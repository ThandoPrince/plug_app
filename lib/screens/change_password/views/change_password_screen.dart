import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';

import 'package:flutter_application_1/global_util/services/controler/authenticated_reset_password_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/change_password_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/secure_kit.dart';
import 'package:flutter_application_1/screens/authen_user_forgot_password/views/authen_user_forgot_password_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _clearErrors() {
    final c = context.read<ChangePasswordController>();
    if (c.error != null || c.fieldErrors.isNotEmpty) c.clearError();
  }

  Future<void> _submit() async {
  FocusScope.of(context).unfocus();

  final ok = await context.read<ChangePasswordController>().changePassword(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );

  if (!mounted || !ok) return;

  Navigator.pop(context);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    FlushbarService.success(
      context,
      'Password changed successfully.',
    );
  });
}

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => AuthenticatedResetPasswordController(),
          child: const ForgotPasswordOtpScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChangePasswordController>();

    return SecureScaffold(
  title: 'Change Password',
  loading: ctrl.isLoading,

  footer: Padding(
    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
    child: PrimaryButton(
      label: 'Change Password',
      loading: ctrl.isLoading,
      onPressed: _submit,
    ),
  ),

  children: [
    SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenHeader(
              icon: Icons.lock_outline_rounded,
              title: 'Update your password',
              subtitle:
                  'Use a strong password you don\'t use anywhere else. You\'ll stay signed in on this device.',
            ),

            GlassCard(
              child: Column(
                children: [
                  GlassField(
                    controller: _currentCtrl,
                    label: 'Current password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    errorText: ctrl.fieldErrors['current_password'],
                    autofill: const [AutofillHints.password],
                    onChanged: (_) => _clearErrors(),
                  ),
                  SizedBox(height: 14.h),
                  GlassField(
                    controller: _newCtrl,
                    label: 'New password',
                    icon: Icons.lock_open_rounded,
                    isPassword: true,
                    errorText: ctrl.fieldErrors['new_password'],
                    helper:
                        'At least ${ChangePasswordController.minLength} characters.',
                    autofill: const [AutofillHints.newPassword],
                    onChanged: (_) => _clearErrors(),
                  ),
                  SizedBox(height: 14.h),
                  GlassField(
                    controller: _confirmCtrl,
                    label: 'Confirm new password',
                    icon: Icons.verified_user_outlined,
                    isPassword: true,
                    errorText: ctrl.fieldErrors['confirm_password'],
                    action: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    autofill: const [AutofillHints.newPassword],
                    onChanged: (_) => _clearErrors(),
                  ),
                  if (ctrl.error != null) ...[
                    SizedBox(height: 16.h),
                    ErrorBanner(ctrl.error!),
                  ],
                ],
              ),
            ),

            SizedBox(height: 8.h),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: ctrl.isLoading ? null : _openForgotPassword,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Kolors.kGray,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Kolors.kGray,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    ),
  ],
);
  }
}
