import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_creation_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ClientDetailsPatchScreen extends StatelessWidget {
  const ClientDetailsPatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = GoRouterState.of(context).uri.queryParameters['email'] ?? '';
    const Color primaryColor = Kolors.kPrimary;

    return ChangeNotifierProvider(
      create: (_) => ClientDetailsController(),
      child: DoubleBackToExit(
        child: Scaffold(
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
              child: Consumer<ClientDetailsController>(
                builder: (context, controller, child) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 35.w),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 40.h),
                              Text(
                                "Almost There",
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              const Text(
                                "Tell us a bit more about yourself",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 40.h),
                              _buildProfilePictureSection(
                                  context, controller, primaryColor),
                              SizedBox(height: 40.h),
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
                                        controller.firstNameController,
                                        "First Name",
                                        Icons.person_outline),
                                    SizedBox(height: 16.h),
                                    _buildTextField(controller.lastNameController,
                                        "Last Name", Icons.person_outline),
                                    SizedBox(height: 16.h),
                                    _buildTextField(
                                      controller.dobController,
                                      "Date of Birth",
                                      Icons.calendar_today_outlined,
                                      readOnly: true,
                                      onTap: () =>
                                          _selectDate(context, controller),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30.h),
                              if (controller.error != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    controller.error!,
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (controller.error != null)
                                SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 35.w, vertical: 20.h),
                        child: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor))
                            : GradientBtn(
                                text: "COMPLETE PROFILE",
                                onTap: () async {
                                  // --- Validate required fields ---
                                  if (controller.profileImagePath == null) {
                                    controller.error =
                                        "Please select a profile picture.";
                                    controller.notifyListeners();
                                    return;
                                  }
                                  if (controller.firstNameController.text
                                      .trim()
                                      .isEmpty) {
                                    controller.error = "First Name is required.";
                                    controller.notifyListeners();
                                    return;
                                  }
                                  if (controller.lastNameController.text
                                      .trim()
                                      .isEmpty) {
                                    controller.error = "Last Name is required.";
                                    controller.notifyListeners();
                                    return;
                                  }
                                  if (controller.dobController.text
                                      .trim()
                                      .isEmpty) {
                                    controller.error =
                                        "Date of Birth is required.";
                                    controller.notifyListeners();
                                    return;
                                  }
                                  final age = controller.dobController.text
                                      .trim()
                                      .toAge();
                                  if (age < 13) {
                                    controller.error =
                                        "You must be at least 18 years old.";
                                    controller.notifyListeners();
                                    return;
                                  }
                                  // Clear any previous error
                                  controller.error = null;
                                  controller.notifyListeners();
        
                                  // --- Save details ---
                                  final success =
                                      await controller.patchClientDetails(email);
                                  if (success && context.mounted) {
                                    context.go('/addaddress?email=$email');
                                  }
                                },
                                btnColor: primaryColor,
                                btnHieght: 58.h,
                                btnWidth: double.infinity,
                                radius: 16,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(BuildContext context,
      ClientDetailsController controller, Color primaryColor) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () =>
              _pickProfileImage(context, controller, fromCamera: false),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 60.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: controller.profileImagePath != null
                  ? FileImage(File(controller.profileImagePath!))
                  : null,
              child: controller.profileImagePath == null
                  ? Icon(Icons.person_add_rounded,
                      size: 40.sp, color: primaryColor)
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () =>
                _pickProfileImage(context, controller, fromCamera: true),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _pickProfileImage(
      BuildContext context, ClientDetailsController controller,
      {bool fromCamera = false}) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice:
          fromCamera ? CameraDevice.front : CameraDevice.rear,
      imageQuality: 80,
    );
    if (image != null) {
      controller.profileImagePath = image.path;
      controller.notifyListeners();
    }
  }

  Future<void> _selectDate(
      BuildContext context, ClientDetailsController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Kolors.kPrimary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Kolors.kPrimary, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Kolors.kPrimary, width: 1.5),
        ),
      ),
    );
  }
}
