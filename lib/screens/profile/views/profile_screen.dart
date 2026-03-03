import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/help_bottom_sheet.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final String email;
  const Profile({super.key, required this.email});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  late final ClientProfileController _profileCtrl;
  late final AddressClientCtrl _addressCtrl;

  @override
  void initState() {
    super.initState();
    _profileCtrl = ClientProfileController();
    _addressCtrl = AddressClientCtrl();
    _profileCtrl.fetchClientByEmail(widget.email);
    _addressCtrl.fetchAddresses(widget.email);
  }

  @override
  void dispose() {
    _profileCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _changeProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint('Selected image path: ${image.path}');
    }
  }

  void _editField(String fieldName, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Edit $fieldName', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $fieldName",
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Kolors.kPrimary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              debugPrint('$fieldName updated to: ${controller.text}');
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Kolors.kPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    debugPrint("User logged out!");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _profileCtrl),
        ChangeNotifierProvider.value(value: _addressCtrl),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent, // Background handled by parent gradient
        body: Consumer2<ClientProfileController, AddressClientCtrl>(
          builder: (context, profileCtrl, addressCtrl, child) {
            if (profileCtrl.isLoading || addressCtrl.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final profile = profileCtrl.clientProfile;
            if (profile == null) {
              return const Center(child: Text('Profile not found', style: TextStyle(color: Colors.white)));
            }

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  children: [
                    _buildProfileHeader(profile),
                    SizedBox(height: 25.h),
                    
                    // Stats Section
                    _buildGlassCard(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Bookings', '12'),
                          _buildVerticalDivider(),
                          _buildStatItem('Points', '450'),
                          _buildVerticalDivider(),
                          _buildStatItem('Rating', profile.rating ?? '5.0'),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10.h),

                    // Information Section
                    _buildGlassCard(
                      child: Column(
                        children: [
                          _buildEditableRow(Icons.person_outline, 'Name', '${profile.firstName} ${profile.lastName}'),
                          _buildDivider(),
                          _buildEditableRow(Icons.email_outlined, 'Email', profile.clientProfile?.emailAddress ?? ''),
                          _buildDivider(),
                          _buildEditableRow(Icons.phone_android_outlined, 'Phone', profile.clientProfile?.mobileNumber ?? ''),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Actions Section
                    _buildActionTile(
                      icon: Ionicons.location_outline,
                      title: "View my Addresses",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LocationScreen(email: widget.email))),
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
                      onTap: _logout,
                    ),
                    
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
              ),
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: profile.profilePic != null
                    ? NetworkImage('http://192.168.18.64:8000${profile.profilePic}')
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
            ),
            GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: Kolors.kPrimary,
                child: Icon(Icons.camera_alt, size: 18.sp, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '${profile.firstName} ${profile.lastName}',
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Kolors.kDark),
        ),
        Text(
          profile.clientProfile?.emailAddress ?? '',
          style: TextStyle(fontSize: 14.sp, color: Kolors.kDark),
        ),
      ],
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return _buildGlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : Kolors.kDark),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp, 
            fontWeight: FontWeight.w500, 
            color: isDestructive ? Colors.redAccent : Kolors.kDark.withOpacity(0.9)
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDestructive ? Colors.redAccent.withOpacity(0.5) : Kolors.kDark),
      ),
    );
  }

  Widget _buildEditableRow(IconData icon, String title, String value) {
    return InkWell(
      onTap: () => _editField(title, value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Kolors.kDark),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp, color: Kolors.kDark)),
                Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Kolors.kDark)),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_note, size: 20.sp, color: Kolors.kDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Kolors.kDark)),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Kolors.kDark.withOpacity(1))),
      ],
    );
  }

  Widget _buildVerticalDivider() => Container(height: 30.h, width: 1, color: Colors.white10);
  
  Widget _buildDivider() => Divider(color: Colors.white.withOpacity(0.05), height: 1);

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
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
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}