import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/screens/Onboarding/terms_of_use/views/privacy_policy_screen.dart';
import 'package:flutter_application_1/screens/Onboarding/terms_of_use/views/terms_of_use_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher.dart';



Future<dynamic> showHelpCenterBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28.0),
      ),
    ),
    builder: (BuildContext sheetContext) {
      Future<void> openWebsite() async {
        final uri = Uri.parse(
          'https://plugprovider.co.za/',
        );

        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (!launched && sheetContext.mounted) {
            FlushbarService.error(
              sheetContext,
              'Unable to open the website.',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Failed to open website: $e');
          }

          if (!sheetContext.mounted) return;

          FlushbarService.error(
            sheetContext,
            'Unable to open the website.',
          );
        }
      }

      return Container(
        height: MediaQuery.of(sheetContext).size.height * 0.75,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Kolors.kPrimary,
              Kolors.kSecondaryLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.0),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Kolors.kDark.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  16.h,
                  20.w,
                  30.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plug App Help Center',
                      style: appStyle(
                        21.0,
                        Kolors.kDark,
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "We're here to help! Find answers to frequently asked "
                      "questions or contact our support team.",
                      style: appStyle(
                        14.0,
                        Kolors.kDark.withOpacity(0.7),
                        FontWeight.normal,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    _SectionLabel('FAQs'),

                    SizedBox(height: 8.h),

                    _GlassSection(
                      children: [
                        _HelpTile(
                          title: 'Can I cancel a booking?',
                          onTap: () {},
                        ),
                        _HelpDivider(),
                        _HelpTile(
                          title: 'How do I track my service?',
                          onTap: () {},
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    _SectionLabel('Contact Us'),

                    SizedBox(height: 8.h),

                    _GlassSection(
                      children: [
                        _ContactRow(
                          icon: MaterialCommunityIcons.email_outline,
                          text: 'support@plugprovider.co.za',
                        ),
                        _HelpDivider(),
                        _ContactRow(
                          icon: MaterialCommunityIcons.phone_outline,
                          text: '0763729362',
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Kolors.kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        onPressed: openWebsite,
                        child: Text(
                          'Visit Full Help Center',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    _SectionLabel('Legal'),

                    SizedBox(height: 8.h),

                    _GlassSection(
                      children: [
                        _HelpTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {
                            Navigator.pop(sheetContext);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),

                        _HelpDivider(),

                        _HelpTile(
                          icon: Icons.description_outlined,
                          title: 'Terms of Use',
                          onTap: () {
                            Navigator.pop(sheetContext);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TermsOfUseScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);


  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: Kolors.kDark.withOpacity(0.55),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  final List<Widget> children;
  const _GlassSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
      ),
      child: Column(children: children),
    );
  }
}

class _HelpDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Kolors.kDark.withOpacity(0.08),
      indent: 16,
      endIndent: 16,
    );
  }
}

class _HelpTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  const _HelpTile({
    required this.title,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      leading: icon != null
          ? Icon(icon, color: Kolors.kPrimary, size: 20.sp)
          : null,
      minLeadingWidth: icon != null ? 0 : null,
      title: Text(
        title,
        style: TextStyle(
          color: Kolors.kDark,
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right_rounded,
        color: Kolors.kDark.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: Kolors.kPrimary, size: 19.sp),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(fontSize: 14.5.sp, color: Kolors.kDark),
          ),
        ],
      ),
    );
  }
}