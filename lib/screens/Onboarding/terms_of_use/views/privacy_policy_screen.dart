import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Using your existing Kolors

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Subtle off-white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Kolors.kDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privacy Policy",
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
              _buildHeaderCard(),
              SizedBox(height: 24.h),
              
              _policySection(
                icon: Icons.person_search_outlined,
                title: "1. Information We Collect",
                body: "We collect personal information such as name, email, phone number, and location to provide our services effectively.",
              ),
              _policySection(
                icon: Icons.auto_graph_outlined,
                title: "2. How We Use Information",
                body: "Information is used to match clients with service providers, improve services, and enhance your overall user experience.",
              ),
              _policySection(
                icon: Icons.location_on_outlined,
                title: "3. Location Data",
                body: "Location access is used to connect you with nearby providers. You may disable location access anytime in your device settings.",
              ),
              _policySection(
                icon: Icons.shield_outlined,
                title: "4. Data Protection",
                body: "Plug implements enterprise-grade security measures to ensure your data is encrypted and protected from unauthorized access.",
              ),
              _policySection(
                icon: Icons.hub_outlined,
                title: "5. Third-Party Services",
                body: "Plug may integrate trusted third-party services for secure payments and analytics to improve our platform.",
              ),

              _policySection(
  icon: Icons.security_outlined,
  title: "5. Device & Security Information",
  body: "For security and fraud prevention purposes, we collect device information such as device identifiers, operating system details, and device fingerprints. We may also log IP addresses to help detect unauthorized access, prevent abuse, and secure your account. This information is not used to personally identify you outside of security and analytics purposes.",
),
_policySection(
  icon: Icons.check_circle_outline,
  title: "6. Consent",
  body: "By using the Plug app, you consent to the collection and processing of your personal data as described in this Privacy Policy. If you do not agree, you should discontinue use of the app.",
),
              
              SizedBox(height: 40.h),
              _buildFooter(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Kolors.kPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.privacy_tip_rounded, color: Kolors.kPrimary, size: 40.sp),
          SizedBox(height: 12.h),
          Text(
            "Your Privacy Matters",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Kolors.kDark),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "Last Updated: March 2026",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _policySection({required IconData icon, required String title, required String body}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            "Have questions about your data?",
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Contact Privacy Support",
              style: TextStyle(color: Kolors.kPrimary, fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}