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
                body: "Welcome to Plug. By accessing or using our application, you agree to comply with and be bound by these Terms of Use in their entirety.",
              ),
              _termsSection(
                icon: Icons.handshake_outlined,
                title: "2. Services",
                body: "Plug acts as a bridge connecting clients with independent service providers. Plug does not directly employ providers unless explicitly stated.",
              ),
              _termsSection(
                icon: Icons.assignment_ind_outlined,
                title: "3. User Responsibilities",
                body: "Users agree to provide accurate data, maintain account security, comply with local laws, and use the platform with integrity.",
              ),
              _termsSection(
                icon: Icons.payments_outlined,
                title: "4. Payments",
                body: "All financial transactions processed through Plug must strictly adhere to our current pricing structures and refund policies.",
              ),
              _termsSection(
                icon: Icons.report_problem_outlined,
                title: "5. Limitation of Liability",
                body: "Plug is not liable for personal disputes between parties. Users agree to resolve conflicts in good faith and hold Plug harmless.",
              ),
              _termsSection(
                icon: Icons.update_rounded,
                title: "6. Changes to Terms",
                body: "We reserve the right to modify these terms. Continued use of the platform after updates constitutes your formal acceptance of new terms.",
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