import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for haptics
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:flutter_application_1/screens/auth/views/registration_success_overlay.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/address_verification_controller.dart';

class AddressVerificationUploadScreen extends StatefulWidget {
  const AddressVerificationUploadScreen({super.key});

  @override
  State<AddressVerificationUploadScreen> createState() =>
      _AddressVerificationUploadScreenState();
}

class _AddressVerificationUploadScreenState
    extends State<AddressVerificationUploadScreen> {
  File? _proofFile;
  File? _idFile;

  Future<void> _pickImage(ImageSource source, bool isId, AddressVerificationController ctrl) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      HapticFeedback.mediumImpact(); // Premium feel
      setState(() {
        if (isId) {
          _idFile = File(file.path);
          ctrl.setIdDocument(_idFile!);
        } else {
          _proofFile = File(file.path);
          ctrl.setProofOfResidence(_proofFile!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    final int clientAddressId = extra['client_address_id'] ?? 0;
    final String? unitNumber = extra['unit_number'];

    return ChangeNotifierProvider(
      create: (_) => AddressVerificationController(),
      child: Consumer<AddressVerificationController>(
        builder: (context, ctrl, child) {
          return DoubleBackToExit(
            child: Scaffold(
              backgroundColor: Kolors.kPrimary, // Matches the header
              body: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // --- Custom Premium Header ---
                      _buildCustomHeader(context),
            
                      // --- Scrollable Content ---
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 15.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35.r),
                              topRight: Radius.circular(35.r),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35.r),
                              topRight: Radius.circular(35.r),
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 25.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 30.h),
                                  _buildAddressBadge(clientAddressId, unitNumber),
                                  SizedBox(height: 25.h),
                                  Text(
                                    "Verification Details",
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Kolors.kDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "To keep our community safe, please upload a clear photo of the documents below.",
                                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, height: 1.4),
                                  ),
                                  SizedBox(height: 30.h),
            
                                  // --- Upload Sections ---
                                  _buildUploadTile(
                                    title: "Proof of Residence",
                                    subtitle: "Utility bill, Lease, or Bank Statement",
                                    file: _proofFile,
                                    onTap: () => _pickImage(ImageSource.gallery, false, ctrl),
                                  ),
            
                                  SizedBox(height: 16.h),
            
                                  _buildUploadTile(
                                    title: "Identification Document",
                                    subtitle: "National ID, Passport, or Driver's License",
                                    file: _idFile,
                                    onTap: () => _pickImage(ImageSource.gallery, true, ctrl),
                                  ),
                                  SizedBox(height: 40.h),

                                  if (ctrl.error != null)
  Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Text(
      ctrl.error!,
      style: TextStyle(
        color: Colors.red,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
                                  
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
            
                      // --- Fixed Bottom Action ---
                      _buildBottomAction(ctrl, clientAddressId),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          Text(
            "Account Security",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBadge(int id, String? unit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Kolors.kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Kolors.kPrimary,
            radius: 18.r,
            child: const Icon(Ionicons.shield_checkmark, color: Colors.white, size: 18),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Verification ID: #PLG-$id", 
                  style: TextStyle(fontWeight: FontWeight.w700, color: Kolors.kPrimary, fontSize: 13.sp)),
              if (unit != null)
                Text("Unit $unit Address", style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTile({required String title, required String subtitle, File? file, required VoidCallback onTap}) {
    bool hasFile = file != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: hasFile ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasFile ? Kolors.kPrimary : Colors.grey.shade200,
            width: hasFile ? 2 : 1.5,
          ),
          boxShadow: hasFile ? [
            BoxShadow(color: Kolors.kPrimary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              height: 54.h,
              width: 54.h,
              decoration: BoxDecoration(
                color: hasFile ? Kolors.kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: hasFile ? Kolors.kPrimary : Colors.grey.shade300),
              ),
              child: Icon(
                hasFile ? Ionicons.checkmark_circle : Ionicons.camera_outline,
                color: hasFile ? Colors.white : Colors.grey.shade400,
                size: 26,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Kolors.kDark)),
                  SizedBox(height: 4.h),
                  Text(
                    hasFile ? "File selected: ${file.path.split('/').last}" : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: hasFile ? Kolors.kPrimary : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildBottomAction(AddressVerificationController ctrl, int id) {
  bool isReady = _idFile != null && _proofFile != null && !ctrl.isLoading;

  return Container(
    padding: EdgeInsets.only(
      left: 25.w,
      right: 25.w,
      top: 20.h,
      bottom: 40.h,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, -5),
        )
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Kolors.kPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              elevation: isReady ? 4 : 0,
            ),
            onPressed: !isReady
                ? null
                : () async {
                    HapticFeedback.lightImpact();

                    final success =
                        await ctrl.submitVerification(context, id);

                    if (success && mounted) {
                      
    _showSuccessOverlay(context);
                    }
                  },
            child: ctrl.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    "FINISH & SUBMIT",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 10.h),

        TextButton(
  onPressed: ctrl.isLoading
      ? null
      : () {
          HapticFeedback.selectionClick();
          _showSuccessOverlay(context);
        },
  child: Text(
    "Skip for now",
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: Kolors.kBlue,
    ),
  ),
),
      ],
    ),
  );
}

void _showSuccessOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => RegistrationSuccessOverlay(
          onCompleted: () {
            
            context.go('/entryPoint');
          },
        ),
      ),
    );
  }
}