import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/delete_account_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/secure_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmationCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmationCtrl.dispose();
    super.dispose();
  }

  void _clearErrors() {
    final c = context.read<DeleteAccountController>();
    if (c.error != null || c.fieldErrors.isNotEmpty) {
      c.clearError();
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text(
          "Are you absolutely sure?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "This action is permanent and cannot be undone.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context.read<DeleteAccountController>().deleteAccount(
          password: _passwordCtrl.text,
          confirmation: _confirmationCtrl.text,
        );

    if (!mounted || !ok) return;

    await AuthSessionController.instance.clearSession();
    if (!mounted) return;
    context.go('/login');
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DeleteAccountController>();

    return SecureScaffold(
      title: 'Delete Account',
      loading: ctrl.isLoading,
      footer: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: ctrl.isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete My Account'),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isLoading ? null : _cancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Kolors.kWhite,
                  disabledBackgroundColor: Kolors.kPrimary.withOpacity(0.55),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: Kolors.kPrimary.withOpacity(0.3),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
      children: [
        const ScreenHeader(
          icon: Icons.warning_amber_rounded,
          title: 'Delete your account',
          subtitle:
              'This is permanent. Your profile, addresses and history will be removed and cannot be recovered.',
        ),
        GlassCard(
          child: Column(
            children: [
              GlassField(
                controller: _passwordCtrl,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                errorText: ctrl.fieldErrors['password'],
                onChanged: (_) => _clearErrors(),
              ),
              SizedBox(height: 14.h),
              GlassField(
                controller: _confirmationCtrl,
                label: 'Type DELETE to confirm',
                icon: Icons.edit_outlined,
                errorText: ctrl.fieldErrors['confirmation'],
                action: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) => _clearErrors(),
              ),
              if (ctrl.error != null) ...[
                SizedBox(height: 16.h),
                ErrorBanner(ctrl.error!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}