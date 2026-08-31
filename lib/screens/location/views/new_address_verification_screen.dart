import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for haptics
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:flutter_application_1/screens/location/views/verify_address_video_capture_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/address_verification_controller.dart';

class AddressVerificationScreen extends StatefulWidget {
  const AddressVerificationScreen({super.key});

  @override
  State<AddressVerificationScreen> createState() =>
      _AddressVerificationScreenState();
}

class _AddressVerificationScreenState
    extends State<AddressVerificationScreen> {
  File? _proofFile;
  File? _idFile;
  File? _videoFile;

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

  // Liveness video is always recorded live via the front camera.
// Future<void> _recordLivenessVideo(
//   AddressVerificationController ctrl,
// ) async {
//   final picker = ImagePicker();

//   final file = await picker.pickVideo(
//     source: ImageSource.camera,
//     preferredCameraDevice: CameraDevice.front,
//     maxDuration: const Duration(seconds: 15),
//   );

//   if (file != null) {
//     HapticFeedback.mediumImpact();

//     setState(() {
//       _videoFile = File(file.path);
//       ctrl.setLivenessVideo(_videoFile!);
//     });
//   }
// }

Future<void> _recordLivenessVideo(
  AddressVerificationController ctrl,
) async {
  HapticFeedback.lightImpact();

  final option = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.r),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                "Liveness Video",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Kolors.kDark,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                "Choose how you want to provide the video.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 20.h),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Kolors.kPrimary.withOpacity(0.1),
                  child: Icon(
                    Ionicons.videocam_outline,
                    color: Kolors.kPrimary,
                  ),
                ),
                title: const Text(
                  "Record Liveness",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  "Use the front camera",
                ),
                onTap: () {
                  Navigator.pop(context, "camera");
                },
              ),

              SizedBox(height: 8.h),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(
                    Ionicons.folder_open_outline,
                    color: Colors.orange,
                  ),
                ),
                title: const Text(
                  "Choose Video",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  "Testing only — select an existing video",
                ),
                onTap: () {
                  Navigator.pop(context, "gallery");
                },
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      );
    },
  );

  if (!mounted || option == null) return;

  // ---------------------------------------------------------
  // TESTING: Pick an existing video
  // ---------------------------------------------------------
  if (option == "gallery") {
    final picker = ImagePicker();

    final file = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (file == null || !mounted) return;

    HapticFeedback.mediumImpact();

    final videoFile = File(file.path);

    setState(() {
      _videoFile = videoFile;
    });

    ctrl.setLivenessVideo(videoFile);

    return;
  }

  // ---------------------------------------------------------
  // NORMAL FLOW: Controlled liveness capture
  // ---------------------------------------------------------
  if (option == "camera") {
    final result = await Navigator.of(context).push<XFile?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const LivenessCaptureScreen(
          maxDuration: Duration(seconds: 10),
          countdownDuration: Duration(seconds: 3),
        ),
      ),
    );

    if (!mounted || result == null) return;

    HapticFeedback.mediumImpact();

    final videoFile = File(result.path);

    setState(() {
      _videoFile = videoFile;
    });

    ctrl.setLivenessVideo(videoFile);
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
              backgroundColor: Kolors.kPrimary, //
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
                                  _buildIdNumberField(ctrl),

                                  SizedBox(height: 16.h),
                                  
            
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
                                  SizedBox(height: 16.h),

_buildUploadTile(
  title: "Liveness Video",
  subtitle: "Record a short selfie video — face clearly visible",
  file: _videoFile,
  icon: Ionicons.videocam_outline,
  onTap: () => _recordLivenessVideo(ctrl),
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
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
    child: Row(
      children: [
        Text(
          "Address Verification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
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

  Widget _buildIdNumberField(
  AddressVerificationController ctrl,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "South African ID Number",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Kolors.kDark,
        ),
      ),

      SizedBox(height: 6.h),

      Text(
        "Enter the ID number shown on your identification document.",
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade500,
        ),
      ),

      SizedBox(height: 10.h),

      TextFormField(
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        maxLength: 13,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: ctrl.setIdNumber,
        decoration: InputDecoration(
          hintText: "e.g. 8001015009087",
          counterText: "",
          prefixIcon: Icon(
            Ionicons.card_outline,
            color: Kolors.kPrimary,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 17.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: Kolors.kPrimary,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildUploadTile({
  required String title,
  required String subtitle,
  File? file,
  required VoidCallback onTap,
  IconData icon = Ionicons.camera_outline,
}) {
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
                hasFile ? Ionicons.checkmark_circle : icon,
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

Future<void> _showVerificationSuccessDialog(
  BuildContext context,
) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (
      dialogContext,
      animation,
      secondaryAnimation,
    ) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Address Verified!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Verification Complete",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Your residential address has been successfully "
                  "verified and is now ready to use.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                GradientBtn(
                  text: "CONTINUE",
                  btnColor: Kolors.kPrimary,
                  btnHieght: 52,
                  btnWidth: double.infinity,
                  radius: 14,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.75,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

  Widget _buildBottomAction(
  AddressVerificationController ctrl,
  int id,
) {
  final bool isReady =
      ctrl.idNumber.isNotEmpty &&
      _idFile != null &&
      _proofFile != null &&
      _videoFile != null &&
      !ctrl.isLoading;

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
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==================================================
        // FINISH & SUBMIT
        // ==================================================
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
                    if (!mounted) return;

                    final verificationContext = context;
                    final success = await ctrl.submitVerification(
                      verificationContext,
                      id,
                    );

                    if (!verificationContext.mounted || !success) return;

                    await _showVerificationSuccessDialog(verificationContext);

                    if (!verificationContext.mounted) return;
                    verificationContext.pop(true);
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

        SizedBox(height: 12.h),

        // ==================================================
        // MAYBE LATER
        // ==================================================
          SizedBox(
  width: double.infinity,
  height: 50.h,
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.grey.shade300,
          Colors.grey.shade500,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: GradientBtn(
  text: "MAYBE LATER",
  textColor: Colors.black,
  btnColor: Colors.grey,
  btnHieght: 50,
  btnWidth: double.infinity,
  radius: 12,
  onTap: ctrl.isLoading
      ? null
      : () {
          HapticFeedback.lightImpact();

          // Return false to MainAddAddressScreen.
          context.pop(false);
        },
),
  ),
),
      ],
    ),
  );
}
}