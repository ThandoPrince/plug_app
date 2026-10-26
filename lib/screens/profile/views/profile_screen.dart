import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/help_bottom_sheet.dart';
import 'package:flutter_application_1/common/widgets/shimmers/profile_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_order_realtime_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_update_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/logout_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/common_error_state.dart';
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
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ImagePicker _picker = ImagePicker();
  late final ClientProfileUpdateController _updateCtrl;

  ImageProvider? _cachedProfileImage;
  String? _cachedProfilePicPath;

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

  Future<void> _onRefresh() async {
    final clientId = AuthSessionController.instance.clientId;
    if (clientId == null) return;

    await context.read<ClientProfileController>().fetchClientByEmail(clientId);
  }

void _confirmLogout() {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      icon: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.logout_rounded,
          color: Colors.red.shade600,
          size: 26.sp,
        ),
      ),
      title: Text(
        'Logout?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: Kolors.kDark,
        ),
      ),
      content: Text(
        'Are you sure you want to logout of your account?',
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1.4,
          fontSize: 14.sp,
          color: Kolors.kDark.withOpacity(0.7),
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Kolors.kDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Kolors.kDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _logout();
                  if (!context.mounted) return;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
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

    final formattedDate = picked.toIso8601String().split('T').first;
    final success = await updateCtrl.updateProfile(dateOfBirth: formattedDate);

    if (!mounted) return;

    if (success) {
      final clientId = AuthSessionController.instance.clientId;
      if (clientId != null) {
        await context.read<ClientProfileController>().fetchClientByEmail(clientId);
      }
      FlushbarService.success(context, updateCtrl.message ?? "Date of birth updated");
    } else {
      FlushbarService.error(context, updateCtrl.errorMessage ?? "Failed to update DOB");
    }
  }

  Future<void> _logout() async {
    final logoutController = LogoutController();

    try {
      Provider.of<TabIndexNotifier>(context, listen: false).reset();
      context.read<ClientOrderRealtimeController>().disconnect();

      await logoutController.logout();

      if (!mounted) return;

      context.go('/login');
      debugPrint("Client logged out successfully");
    } catch (e) {
      debugPrint("Logout failed: $e");

      if (!mounted) return;

      FlushbarHelper.createError(message: "Logout failed. Please try again.").show(context);
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
    final success = await _updateCtrl.updateProfile(profilePicture: file);

    if (!mounted) return;

    if (success) {
      final clientId = AuthSessionController.instance.clientId;
      if (clientId != null) {
        await context.read<ClientProfileController>().fetchClientByEmail(clientId);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlushbarService.success(context, _updateCtrl.message ?? "Profile picture updated");
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlushbarService.error(context, _updateCtrl.errorMessage ?? "Update failed");
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
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Kolors.kDark),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14.sp, color: Kolors.kDark),
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
                  textColor: Kolors.kDark,
                  btnHieght: 45.h,
                  btnWidth: double.infinity,
                  radius: 12,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
                SizedBox(height: 10.h),
                Consumer<ClientProfileUpdateController>(
                  builder: (context, updateCtrl, _) {
                    return GradientBtn(
                      text: updateCtrl.isLoading ? "Saving..." : "Save Changes",
                      btnColor: Kolors.kPrimary,
                      btnHieght: 45.h,
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
                                lastName = parts.length > 1 ? parts.sublist(1).join(" ") : null;
                              }

                              Navigator.of(dialogContext).pop();

                              final success = await updateCtrl.updateProfile(
                                firstName: firstName,
                                lastName: lastName,
                              );

                              if (!mounted) return;

                              if (success) {
                                final clientId = AuthSessionController.instance.clientId;
                                if (clientId != null) {
                                  await context.read<ClientProfileController>().fetchClientByEmail(clientId);
                                }
                                FlushbarService.success(context, updateCtrl.message ?? "Profile updated");
                              } else {
                                FlushbarService.error(context, updateCtrl.errorMessage ?? "Update failed");
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
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ClientProfileController>(
        builder: (context, profileCtrl, child) {
          return Selector<AddressClientCtrl, bool>(
            selector: (_, addressCtrl) => addressCtrl.isLoading,
            builder: (context, isAddressLoading, _) {
              if (profileCtrl.isLoading || isAddressLoading) {
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [ProfileSkeleton()],
                );
              }

              if (profileCtrl.errorMessage != null) {
                return RefreshIndicator(
                  color: Kolors.kPrimary,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  child: CommonErrorState(
                    onRefresh: _onRefresh,
                    title: "Unable to load profile",
                    message: profileCtrl.errorMessage!,
                    icon: Icons.person_off_outlined,
                  ),
                );
              }

              final profile = profileCtrl.clientProfile;

              if (profile == null) {
                return RefreshIndicator(
                  color: Kolors.kPrimary,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  child: CommonErrorState(
                    onRefresh: _onRefresh,
                    icon: Icons.person_off_outlined,
                    title: "Profile Not Found",
                    message: "We couldn't find your profile information.",
                  ),
                );
              }

              return SafeArea(
                child: RefreshIndicator(
                  color: Kolors.kPrimary,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Column(
                      children: [
                        _buildProfileHeader(profile),
                        SizedBox(height: 25.h),

                        _buildCard(
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
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

                        SizedBox(height: 14.h),

                        _buildCard(
                          child: Column(
                            children: [
                              _buildEditableRow(
                                Icons.person_outline,
                                'Name',
                                '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim(),
                              ),
                              _buildDivider(),
                              _buildEditableRow(
                                Icons.cake_outlined,
                                'Date of Birth',
                                profile.dateOfBirth?.toIso8601String().split('T').first ?? '',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.h),

                        _buildActionTile(
                          icon: Ionicons.shield_checkmark_outline,
                          title: "Account & Security",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccountSecurityScreen(profile: profile),
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
                              MaterialPageRoute(builder: (_) => LocationScreen()),
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  ImageProvider _resolveImage(String? path) {
    if (_cachedProfilePicPath == path && _cachedProfileImage != null) {
      return _cachedProfileImage!;
    }

    final baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
    final ImageProvider image;

    if (path == null || path.isEmpty) {
      image = const AssetImage('assets/default_profile.png');
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      image = NetworkImage(path);
    } else {
      final uri = Uri.parse(baseUrl).resolve(path).toString();
      image = NetworkImage(uri);
    }

    _cachedProfilePicPath = path;
    _cachedProfileImage = image;
    return image;
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
                  color: Colors.white.withOpacity(0.8),
                  width: 4.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(image: profileImage),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 56.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profileImage,
                ),
              ),
            ),
            GestureDetector(
              onTap: _changeProfilePicture,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 16.r,
                  backgroundColor: Kolors.kPrimary,
                  child: Icon(
                    Icons.camera_alt,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim(),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Kolors.kDark,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          profile.clientProfile?.emailAddress ?? '',
          style: TextStyle(
            fontSize: 13.sp,
            color: Kolors.kDark.withOpacity(0.6),
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
    final Color accent = isDestructive ? Colors.red.shade600 : Kolors.kPrimary;

    return _buildCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 2.h,
        ),
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: isDestructive ? Colors.red.shade600 : Kolors.kDark.withOpacity(0.8),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red.shade600 : Kolors.kDark.withOpacity(0.9),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18.sp,
          color: isDestructive ? Colors.red.shade300 : Kolors.kDark.withOpacity(0.4),
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
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Kolors.kPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17.sp, color: Kolors.kDark.withOpacity(0.8)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Kolors.kDark.withOpacity(0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value.isEmpty ? "Not set" : value,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: value.isEmpty ? Kolors.kDark.withOpacity(0.35) : Kolors.kDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Icon(
            //   Icons.edit_rounded,
            //   size: 15.sp,
            //   color: Kolors.kDark.withOpacity(0.3),
            // ),
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
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Kolors.kDark.withOpacity(0.55),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28.h,
      width: 1,
      color: Kolors.kDark.withOpacity(0.1),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Kolors.kDark.withOpacity(0.06),
      height: 1,
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Kolors.kOffWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}