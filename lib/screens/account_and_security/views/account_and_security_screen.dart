import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

import 'package:flutter_application_1/global_util/services/controler/change_password_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/delete_account_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';
import 'package:flutter_application_1/global_util/services/widgets/secure_kit.dart';
import 'package:flutter_application_1/screens/account_and_security/views/delete_account_screen.dart';
import 'package:flutter_application_1/screens/change_password/views/change_password_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AccountSecurityScreen extends StatelessWidget {
  final ClientDetailModel profile;
  const AccountSecurityScreen({super.key, required this.profile});



  void _openDeleteAccount(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => DeleteAccountController(),
        child: const DeleteAccountScreen(),
      ),
    ),
  );
}

  // void _showDeleteAccountDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
  //       icon: Container(
  //         padding: EdgeInsets.all(12.w),
  //         decoration: BoxDecoration(
  //           color: Colors.red.shade50,
  //           shape: BoxShape.circle,
  //         ),
  //         child: Icon(Icons.delete_outline_rounded,
  //             color: Colors.red.shade600, size: 26.sp),
  //       ),
  //       title: const Text(
  //         'Delete account?',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(fontWeight: FontWeight.w700),
  //       ),
  //       content: const Text(
  //         'This is permanent and cannot be undone. Your profile data, history and settings will be removed.',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(height: 1.4, color: Colors.black87),
  //       ),
  //       actionsAlignment: MainAxisAlignment.spaceBetween,
  //       actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
  //       actions: [
  //         Expanded(
  //           child: ElevatedButton(
  //             onPressed: () => Navigator.pop(ctx),
  //                     style: ElevatedButton.styleFrom(
  //               backgroundColor: Kolors.kPrimary,
  //               foregroundColor: Colors.white,
  //               elevation: 0,
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10.r)),
  //             ),
  //             child: const Text('Cancel',
  //                 style: TextStyle(
  //                     color: Colors.white, fontWeight: FontWeight.w600)),
  //           ),
  //         ),
  //         SizedBox(width: 8.w),
  //         Expanded(
  //           child: ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(ctx);
  //               // TODO: Execute account deletion via API
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red.shade600,
  //               foregroundColor: Colors.white,
  //               elevation: 0,
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10.r)),
  //             ),
  //             child: const Text('Delete'),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _openChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ChangePasswordController(),
          child: const ChangePasswordScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = profile.clientProfile?.emailAddress;
    final mobile = profile.clientProfile?.mobileNumber;

    return SecureScaffold(
      title: 'Account & Security',
      footer: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
        child: OutlinedButton.icon(
          onPressed: () => _openDeleteAccount(context),
          icon: Icon(Icons.delete_outline_rounded,
              size: 18.sp, color: Colors.red),
          label: Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50.h),
            side: BorderSide(color: Colors.red.shade200.withOpacity(0.5)),
            backgroundColor: Colors.red.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
      children: [
        const ScreenHeader(
          icon: Icons.shield_outlined,
          title: 'Account & Security',
          subtitle: 'Manage how you sign in and how we can reach you.',
        ),
        const _SectionLabel('Contact'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.email_outlined,
                title: 'Email address',
                subtitle: email ?? 'Not available',
                // Pass onTap once the change-email flow exists.
              ),
              const _TileDivider(),
              _SettingTile(
                icon: Icons.phone_android_outlined,
                title: 'Mobile number',
                subtitle: mobile ?? 'Not available',
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        const _SectionLabel('Security'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: _SettingTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change password',
            subtitle: 'Update the password you use to sign in',
            onTap: () => _openChangePassword(context),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 68.w,
        color: Colors.white.withOpacity(0.1),
      );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: Kolors.kDark, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Kolors.kDark,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Kolors.kDark.withOpacity(0.65),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    color: Kolors.kDark.withOpacity(0.5), size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}