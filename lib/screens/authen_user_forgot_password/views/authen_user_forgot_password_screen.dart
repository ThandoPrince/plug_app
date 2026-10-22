import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/authenticated_reset_password_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/secure_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  static const int _otpLength = 6; // match the length your backend generates

  final _otpCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthenticatedResetPasswordController>().requestOtp();
      }
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    _otpCtrl.clear();
    final ok =
        await context.read<AuthenticatedResetPasswordController>().requestOtp();
    if (!mounted || !ok) return;
    FlushbarService.success(context, 'A new code has been sent.');
  }

 Future<void> _submit() async {
  FocusScope.of(context).unfocus();

  final ok = await context
      .read<AuthenticatedResetPasswordController>()
      .confirmReset(
        otp: _otpCtrl.text,
        newPassword: _newCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );

  if (!mounted || !ok) return;

  final nav = Navigator.of(context);

  // Back out of this screen AND ChangePasswordScreen.
  nav.pop();
  if (nav.canPop()) {
    nav.pop();
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlushbarService.success(
      context,
      'Password changed successfully.',
    );
  });
}
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthenticatedResetPasswordController>();

    return SecureScaffold(
      title: 'Reset Password',
      loading: ctrl.isBusy,

      // ---- Pinned bottom button ----
      footer: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
        child: PrimaryButton(
          label: 'Reset Password',
          loading: ctrl.isSubmitting,
          onPressed: (ctrl.isBusy || !ctrl.codeSent) ? null : _submit,
        ),
      ),

      children: [
        ScreenHeader(
          icon: Icons.mark_email_read_outlined,
          title: 'Verify it\'s you',
          subtitle: ctrl.isSending && !ctrl.codeSent
              ? 'Sending a verification code...'
              : ctrl.maskedEmail.isNotEmpty
                  ? 'Enter the code we sent to ${ctrl.maskedEmail}, then choose a new password.'
                  : 'Enter the code we emailed you, then choose a new password.',
        ),

        // ---- Step 1: code ----
        GlassCard(
          child: Column(
            children: [
              GlassField(
                controller: _otpCtrl,
                label: 'Verification code',
                centered: true,
                keyboardType: TextInputType.number,
                maxLength: _otpLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofill: const [AutofillHints.oneTimeCode],
                errorText: ctrl.fieldErrors['otp'],
                onChanged: (_) => ctrl.clearError(),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Didn\'t get it?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                  TextButton(
                    onPressed: ctrl.canResend ? _resend : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white38,
                      minimumSize: Size(0, 32.h),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    child: Text(
                      ctrl.resendSecondsLeft > 0
                          ? 'Resend in ${ctrl.resendSecondsLeft}s'
                          : 'Resend code',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // ---- Step 2: new password ----
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassField(
                controller: _newCtrl,
                label: 'New password',
                icon: Icons.lock_open_rounded,
                isPassword: true,
                errorText: ctrl.fieldErrors['new_password'],
                autofill: const [AutofillHints.newPassword],
                onChanged: (_) {
                  ctrl.clearError();
                  setState(() {}); // refresh checklist
                },
              ),
              SizedBox(height: 12.h),
              _PasswordChecklist(password: _newCtrl.text),
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
                onChanged: (_) => ctrl.clearError(),
              ),
              if (ctrl.error != null) ...[
                SizedBox(height: 16.h),
                ErrorBanner(ctrl.error!),
              ],
            ],
          ),
        ),

        SizedBox(height: 12.h),
      ],
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  final String password;
  const _PasswordChecklist({required this.password});

  @override
  Widget build(BuildContext context) {
    final rules = <(String, bool)>[
      (
        'At least ${AuthenticatedResetPasswordController.minLength} characters',
        password.length >= AuthenticatedResetPasswordController.minLength
      ),
      ('One uppercase letter', RegExp(r'[A-Z]').hasMatch(password)),
      ('One lowercase letter', RegExp(r'[a-z]').hasMatch(password)),
      ('One number', RegExp(r'\d').hasMatch(password)),
    ];

    return Wrap(
      spacing: 14.w,
      runSpacing: 6.h,
      children: [
        for (final (label, met) in rules)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                met ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 14.sp,
                color: met ? Kolors.kGray : Kolors.kDark,
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: met ? Kolors.kGray : Kolors.kDark,
                ),
              ),
            ],
          ),
      ],
    );
  }
}