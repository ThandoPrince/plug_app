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

            _FormCard(
              child: Column(
                children: [
                  _SolidField(
                    controller: _currentCtrl,
                    label: 'Current password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    errorText: ctrl.fieldErrors['current_password'],
                    autofill: const [AutofillHints.password],
                    onChanged: (_) => _clearErrors(),
                  ),
                  SizedBox(height: 14.h),
                  _SolidField(
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
                  _SolidField(
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
                    color: Kolors.kPrimary,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Kolors.kPrimary,
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

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Kolors.kOffWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SolidField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final String? errorText;
  final String? helper;
  final Iterable<String>? autofill;
  final TextInputAction action;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _SolidField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.errorText,
    this.helper,
    this.autofill,
    this.action = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_SolidField> createState() => _SolidFieldState();
}

class _SolidFieldState extends State<_SolidField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.action,
      autofillHints: widget.autofill,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: TextStyle(color: Kolors.kDark, fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helper,
        errorText: widget.errorText,
        labelStyle: TextStyle(color: Kolors.kDark.withOpacity(0.6)),
        floatingLabelStyle: const TextStyle(color: Kolors.kPrimary),
        prefixIcon: Icon(widget.icon, color: Kolors.kDark, size: 20.sp),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Kolors.kDark.withOpacity(0.5),
                  size: 20.sp,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: _border(Kolors.kDark.withOpacity(0.12)),
        enabledBorder: _border(Kolors.kDark.withOpacity(0.12)),
        focusedBorder: _border(Kolors.kPrimary, width: 1.5),
        errorBorder: _border(Colors.red.shade400),
        focusedErrorBorder: _border(Colors.red.shade400, width: 1.5),
      ),
    );
  }
}