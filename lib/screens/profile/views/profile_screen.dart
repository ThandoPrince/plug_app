import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/help_bottom_sheet.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_update_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/logout_controller.dart';
import 'package:flutter_application_1/screens/account_and_security/views/account_and_security_screen.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/tab_lifecycle_controller.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:flutter_application_1/screens/profile/widgets/full_screen_image_viewer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {


  
  

  const Profile({
    super.key,
    
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  late final ClientProfileUpdateController _updateCtrl;

  
 

 @override
void initState() {
  super.initState();

  _updateCtrl = ClientProfileUpdateController();


 


}

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final lifecycle = context.read<TabLifecycleController>();
  final profileCtrl = context.read<ClientProfileController>();

  if (!lifecycle.isLoaded(3)) {
    lifecycle.markLoaded(3);

    final clientId = AuthSessionController.instance.clientId;
    if (clientId != null) {
      profileCtrl.fetchClientByEmail(clientId);
    }
  }
}

  @override
  void dispose() {
    
    _updateCtrl.dispose();
    
    super.dispose();
  }

  void _confirmLogout() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: GradientBtn(
  text: "Cancel",
  btnColor: Colors.grey.shade200,
  textColor: Colors.black,
  btnHieght: 50,
  btnWidth: double.infinity,
  radius: 14,
  onTap: () {
    Navigator.of(dialogContext).pop();
  },
),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Kolors.kPrimary,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
  ),
  onPressed: () async {
    Navigator.of(dialogContext).pop();

    await _logout();

    if (!context.mounted) return;
  },
  child: const Text(
    "Logout",
    style: TextStyle(
      color: Kolors.kOffWhite,
      fontWeight: FontWeight.bold,
    ),
  ),
),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _editDateOfBirth() async {
  final updateCtrl = context.read<ClientProfileUpdateController>();

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Kolors.kPrimary,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked == null) return;

  final formattedDate =
      picked.toIso8601String().split('T').first;

  final success = await updateCtrl.updateProfile(
    dateOfBirth: formattedDate,
  );

  if (!mounted) return;

  if (success) {

    final clientId = AuthSessionController.instance.clientId;
  if (clientId != null) {
   await context.read<ClientProfileController>()
        .fetchClientByEmail(clientId);
  }
    

    FlushbarService.success(
      context,
      updateCtrl.message ?? "Date of birth updated",
    );
  } else {
    FlushbarService.error(
      context,
      updateCtrl.errorMessage ?? "Failed to update DOB",
    );
  }
}

  Future<void> _logout() async {
  final logoutController = LogoutController();

  try {
    Provider.of<TabIndexNotifier>(context, listen: false).reset();

    await logoutController.logout();

    if (!mounted) return;

    context.go('/login');

    debugPrint("Client logged out successfully");
  } catch (e) {
    debugPrint("Logout failed: $e");

    if (!mounted) return;

    FlushbarHelper.createError(
      message: "Logout failed. Please try again.",
    ).show(context);
  }
}

  Future<void> _changeProfilePicture() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
    imageQuality: 85,
  );

  if (image == null) return;

  final file = File(image.path);

  final success = await _updateCtrl.updateProfile(
    profilePicture: file,
  );

  if (!mounted) return;

  if (success) {
    final clientId = AuthSessionController.instance.clientId;
  if (clientId != null) {
  await  context.read<ClientProfileController>()
        .fetchClientByEmail(clientId);
  }
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlushbarService.success(
        context,
        _updateCtrl.message ?? "Profile picture updated",
      );
    });
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlushbarService.error(
        context,
        _updateCtrl.errorMessage ?? "Update failed",
      );
    });
  }
}

  void _editField(String fieldName, String currentValue) {
  final controller = TextEditingController(text: currentValue);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          "Edit $fieldName",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $fieldName",
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Kolors.kPrimary),
            ),
          ),
        ),
        actions: [
          Column(
            children: [
              GradientBtn(
                text: "Cancel",
                btnColor: Colors.grey.shade300,
                textColor: Colors.black,
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
              SizedBox(height: 10.h),

              Consumer<ClientProfileUpdateController>(
                builder: (context, updateCtrl, _) {
                  return GradientBtn(
                    text: updateCtrl.isLoading
                        ? "Saving..."
                        : "Save Changes",
                    btnColor: Kolors.kPrimary,
                    btnHieght: 50.h,
                    btnWidth: double.infinity,
                    radius: 12,
                    onTap: updateCtrl.isLoading
                        ? null
                        : () async {
                            final text = controller.text.trim();

                            String? firstName;
                            String? lastName;

                            if (fieldName == "Name") {
                              final parts = text.split(RegExp(r'\s+'));
                              firstName = parts.isNotEmpty ? parts.first : null;
                              lastName = parts.length > 1
                                  ? parts.sublist(1).join(" ")
                                  : null;
                            }

                            // close dialog FIRST (prevents Navigator conflicts)
                            Navigator.of(dialogContext).pop();

                            final success =
                                await updateCtrl.updateProfile(
                              firstName: firstName,
                              lastName: lastName,
                            );

                            if (!mounted) return;

                            if (success) {
                              final clientId = AuthSessionController.instance.clientId;
  if (clientId != null) {
   await context.read<ClientProfileController>()
        .fetchClientByEmail(clientId);
  }
    

                              FlushbarService.success(
                                context,
                                updateCtrl.message ?? "Profile updated",
                              );
                            } else {
                              FlushbarService.error(
                                context,
                                updateCtrl.errorMessage ?? "Update failed",
                              );
                            }
                          },
                  );
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer2<ClientProfileController, AddressClientCtrl>(
        builder: (context, profileCtrl, addressCtrl, child) {
          if (profileCtrl.isLoading || addressCtrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
    
          final profile = profileCtrl.clientProfile;
    
          if (profile == null) {
            return const Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
    
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 20.h,
              ),
              child: Column(
                children: [
                  _buildProfileHeader(profile),
                  SizedBox(height: 25.h),
    
                  _buildGlassCard(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                       
                        _buildVerticalDivider(),
                        _buildStatItem('Points', '0'),
                        _buildVerticalDivider(),
                        _buildStatItem(
                          'Rating',
                          (profile.rating?.toString().isNotEmpty ?? false)
                              ? profile.rating.toString()
                              : '0.0',
                        ),
                      ],
                    ),
                  ),
    
                  SizedBox(height: 10.h),
    
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildEditableRow(
                          Icons.person_outline,
                          'Name',
                          '${profile.firstName ?? ''} ${profile.lastName ?? ''}'
                              .trim(),
                        ),
                        
                        _buildDivider(),
                        _buildEditableRow(
      Icons.cake_outlined,
      'Date of Birth',
      profile.dateOfBirth?.toIso8601String().split('T').first ?? ''
    ),
                      ],
                    ),
                  ),
    
                  SizedBox(height: 10.h),
    
                  _buildActionTile(
      icon: Ionicons.shield_checkmark_outline,
      title: "Account & Security",
      onTap: () {
        Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountSecurityScreen(
    profile: profile,
        ),
      ),
    );
      },
    ),
    
                  _buildActionTile(
                    icon: Ionicons.location_outline,
                    title: "View My Addresses",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationScreen(),
                        ),
                      );
                    },
                  ),
    
                  _buildActionTile(
                    icon: Ionicons.help_buoy_outline,
                    title: "Help & Support",
                    onTap: () => showHelpCenterBottomSheet(context),
                  ),
    
                  _buildActionTile(
                    icon: Ionicons.log_out_outline,
                    title: "Logout",
                    isDestructive: true,
                    onTap: _confirmLogout,
                  ),
    
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider _resolveImage(String? path) {
  final baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

  if (path == null || path.isEmpty) {
    return const AssetImage('assets/default_profile.png');
  }

  // already absolute URL → use directly
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }

  // relative path → safely join
  final uri = Uri.parse(baseUrl).resolve(path).toString();
  return NetworkImage(uri);
}

  Widget _buildProfileHeader(dynamic profile) {
    final profileImage = _resolveImage(profile.profilePic);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 4,
                ),
              ),
              child: GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          image: profileImage,
        ),
      ),
    );
  },
  child: CircleAvatar(
    radius: 60.r,
    backgroundColor: Colors.grey.shade200,
    backgroundImage: profileImage,
  ),
),
            ),
            GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: Kolors.kPrimary,
                child: Icon(
                  Icons.camera_alt,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim(),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Kolors.kDark,
          ),
        ),
        Text(
          profile.clientProfile?.emailAddress ?? '',
          style: TextStyle(
            fontSize: 14.sp,
            color: Kolors.kDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return _buildGlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Kolors.kDark,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isDestructive
                ? Colors.redAccent
                : Kolors.kDark.withOpacity(0.9),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive
              ? Colors.redAccent.withOpacity(0.5)
              : Kolors.kDark,
        ),
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String title, String value) {
    return InkWell(
      onTap: () {
  if (title == 'Date of Birth') {
    _editDateOfBirth();
  } else {
    _editField(title, value);
  }
},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: Kolors.kDark,
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Kolors.kDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Kolors.kDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.edit_note,
              size: 20.sp,
              color: Kolors.kDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Kolors.kDark,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Kolors.kDark.withOpacity(1),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30.h,
      width: 1,
      color: Colors.white10,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      height: 1,
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}