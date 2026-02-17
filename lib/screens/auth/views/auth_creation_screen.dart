import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/global_util/services/controler/client_auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthCreationScreen extends StatelessWidget {
  const AuthCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  child: Consumer<ClientAuthProvider>(
                    builder: (context, provider, child) {
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 50.h),

                          // --- Header ---
                          Text(
                            "Join us at Plug",
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          const Text(
                            "Create an account to start booking services",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 50.h),

                          // --- Form Card ---
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: provider.emailController,
                                  hint: "Email Address",
                                  icon: Icons.email_outlined,
                                  errorText: provider.fieldErrors['email'],
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: provider.mobileController,
                                  hint: "Mobile Number",
                                  icon: Icons.phone_android_outlined,
                                  type: TextInputType.phone,
                                  errorText: provider.fieldErrors['mobile'],
                                ),
                                SizedBox(height: 16.h),
                                _buildTextField(
                                  controller: provider.passwordController,
                                  hint: "Password",
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  errorText: provider.fieldErrors['password'],
                                ),
                                SizedBox(height: 6.h),
                                                                  
                                     SizedBox(height: 4.h),
                              ],
                            ),
                          ),

                          // --- Non-field / general error display ---
                       // --- Non-field / general error display ---
if (provider.error != null) ...[
  SizedBox(height: 16.h),
  Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.redAccent.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 70.w, 
        ),
        child: Text(
          provider.error!,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            
          ),
          softWrap: true,
          overflow: TextOverflow.visible
          
        ),
      ),
    ),
  ),
],

                        ],
                      );
                    },
                  ),
                ),
              ),

              // --- Bottom Actions ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
                child: Consumer<ClientAuthProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        provider.isLoading
                            ? const Center(child: CircularProgressIndicator(color: primaryColor))
                            : GradientBtn(
                                text: "CREATE ACCOUNT",
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  final success = await provider.register();

                                  // Navigate only on success
                                  if (context.mounted && success) {
                                    context.go(
                                        '/clientDetailsPatch?email=${provider.emailController.text.trim()}');
                                  }
                                },
                                btnColor: primaryColor,
                                radius: 16,
                                btnHieght: 58.h,
                                btnWidth: double.infinity,
                              ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ReusableText(
                              text: "Already part of the community? ",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go( "/login"),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.sp,
                                  color: Kolors.kBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Updated TextFormField ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? errorText,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: Kolors.kPrimary, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorText != null ? Colors.red : Kolors.kPrimary, width: 1.5),
        ),
      ),
    );
  }
}
