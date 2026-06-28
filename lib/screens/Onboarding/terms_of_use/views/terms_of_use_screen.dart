import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Kolors.kDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Terms of Use",
          style: TextStyle(
            color: Kolors.kDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroCard(),
              SizedBox(height: 24.h),
              
              _termsSection(
                icon: Icons.gavel_rounded,
                title: "1. Introduction",
                body: "Welcome to Plug. By accessing or using our application, you agree to comply with and be bound by these Terms of Use. If you do not agree with these terms, you must discontinue use of the platform immediately."
              ),
              _termsSection(
                icon: Icons.handshake_outlined,
                title: "2. Services",
                                body: "Plug is a digital marketplace that connects clients with independent service providers. Plug does not directly provide services and is not responsible for service delivery, quality, timing, or outcomes provided by third-party providers."

              ),
              _termsSection(
                icon: Icons.assignment_ind_outlined,
                title: "3. User Responsibilities",
                body: "Users agree to provide accurate information, maintain account security, use the platform lawfully, and not engage in fraudulent, abusive, or deceptive behavior. Users are responsible for all activity conducted through their accounts."
              ),
              _termsSection(
                icon: Icons.payments_outlined,
                title: "4. Payments",
                body: "All payments processed through Plug must comply with platform pricing, refund policies, and transaction rules. Users agree not to initiate unauthorized chargebacks or fraudulent payment activity."
              ),
              _termsSection(
                icon: Icons.report_problem_outlined,
                title: "5. Limitation of Liability",
                body: "To the maximum extent permitted by law, Plug is not liable for any direct, indirect, incidental, consequential, or punitive damages arising from use of the platform. This includes disputes between users, service delays, cancellations, or service quality issues."
              ),
              _termsSection(
                icon: Icons.update_rounded,
                title: "6. Changes to Terms",
                body: "We reserve the right to modify these terms. Continued use of the platform after updates constitutes your formal acceptance of new terms.",
              ),
              _termsSection(
  icon: Icons.no_accounts_outlined,
  title: "7. Account Suspension & Termination",
  body: "We reserve the right to suspend or terminate accounts that violate these Terms, engage in fraudulent activity, abuse the platform, or compromise the safety of other users.",
),
_termsSection(
  icon: Icons.storefront_outlined,
  title: "8. Independent Service Providers",
  body: "Service providers on Plug operate as independent contractors and are not employees of Plug. Plug is not responsible for the quality, safety, or outcomes of services provided by third parties.",
),
_termsSection(
  icon: Icons.balance_outlined,
  title: "9. Dispute Resolution",
  body: "Users agree that any disputes arising between clients and service providers must first be resolved through communication. Plug may assist in mediation but is not legally liable for unresolved disputes.",
),
_termsSection(
  icon: Icons.block_outlined,
  title: "10. Prohibited Conduct",
  body: "Users may not engage in fraudulent activity, harassment, impersonation, abusive behavior, or misuse of the platform. Any attempt to manipulate pricing, bookings, or ratings is strictly prohibited.",
),
_termsSection(
  icon: Icons.copyright_outlined,
  title: "11. Intellectual Property",
  body: "All branding, design, code, and content within the Plug application remain the intellectual property of Plug unless otherwise stated. Unauthorized copying or redistribution is prohibited.",
),
_termsSection(
  icon: Icons.warning_amber_outlined,
  title: "12. Limitation of Liability",
  body: "Plug is not liable for any direct, indirect, incidental, or consequential damages arising from use of the platform, including but not limited to service disputes, delays, or user interactions.",
),
_termsSection(
  icon: Icons.gavel_rounded,
  title: "13. Governing Law",
  body: "These Terms are governed by the laws of South Africa. Any legal disputes shall be subject to the jurisdiction of South African courts.",
),
_termsSection(
  icon: Icons.verified_user_outlined,
  title: "14. Acceptance of Terms",
  body: "By using the Plug application, you confirm that you have read, understood, and agreed to these Terms of Use. Continued use of the platform constitutes ongoing acceptance of any updates.",
),
_termsSection(
  icon: Icons.security_outlined,
  title: "15. Data & Security",
  body: "We may collect device information, IP addresses, and usage data for security, fraud prevention, and platform integrity. This data is handled in accordance with our Privacy Policy.",
),
              
              SizedBox(height: 40.h),
              _buildAcceptanceNote(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary.withOpacity(0.1), Kolors.kPrimary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined, color: Kolors.kPrimary, size: 40.sp),
          SizedBox(height: 12.h),
          Text(
            "Service Agreement",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Kolors.kDark),
          ),
          SizedBox(height: 8.h),
          Text(
            "Please read these terms carefully before using the Plug platform.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _termsSection({required IconData icon, required String title, required String body}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: Kolors.kPrimary, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Kolors.kDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceNote() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "By using this app, you signify your irrevocable acceptance of these terms.",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

