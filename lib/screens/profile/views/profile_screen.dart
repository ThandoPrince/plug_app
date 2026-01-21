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

    // Fetch data only once
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
      // Handle image upload logic here
      print('Selected image path: ${image.path}');
    }
  }

  void _editField(String fieldName, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              print('$fieldName updated to: ${controller.text}');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // TODO: Implement logout logic
    print("User logged out!");
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _profileCtrl),
        ChangeNotifierProvider.value(value: _addressCtrl),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer2<ClientProfileController, AddressClientCtrl>(
          builder: (context, profileCtrl, addressCtrl, child) {
            if (profileCtrl.isLoading || addressCtrl.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            if (profileCtrl.errorMessage != null) {
              return Center(
                child: Text(
                  profileCtrl.errorMessage!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              );
            }

            final profile = profileCtrl.clientProfile;
            if (profile == null) {
              return const Center(
                  child: Text(
                'No profile available.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ));
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile picture
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 65.r,
                          backgroundImage: profile.profilePic != null
                              ? NetworkImage(
                                  'http://192.168.18.64:8000${profile.profilePic}')
                              : const AssetImage(
                                      'assets/default_profile.png')
                                  as ImageProvider,
                        ),
                        GestureDetector(
                          onTap: _changeProfilePicture,
                          child: CircleAvatar(
                            radius: 18.r,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.edit,
                                size: 18.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Main info card
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditableRow(
                              'Name', '${profile.firstName} ${profile.lastName}'),
                          _buildEditableRow(
                              'Email', profile.clientProfile?.emailAddress ?? ''),
                          _buildEditableRow(
                              'Phone', profile.clientProfile?.mobileNumber ?? ''),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Stats card
                    _buildGlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Bookings', '12'),
                          _buildStatItem('Points', '450'),
                          _buildStatItem('Rating', profile.rating ?? '0.0'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // View Addresses card
                    _buildGlassCard(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LocationScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "View my Addresses",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_right,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Help center
                    _buildGlassCard(
                      child: InkWell(
                        onTap: () => showHelpCenterBottomSheet(context),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                MaterialCommunityIcons.lifebuoy,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Help & Support",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              const Icon(Icons.keyboard_arrow_right,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Logout card
                    _buildGlassCard(
                      child: InkWell(
                        onTap: _logout,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                MaterialCommunityIcons.logout,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Editable row helper
  Widget _buildEditableRow(String title, String value) {
    return GestureDetector(
      onTap: () => _editField(title, value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 16.sp, color: Colors.black.withOpacity(0.8))),
                SizedBox(width: 8.w),
                const Icon(Icons.edit, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Stat item helper
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        SizedBox(height: 4.h),
        Text(label,
            style: TextStyle(
                fontSize: 14.sp, color: Colors.black.withOpacity(0.7))),
      ],
    );
  }

  // Glass card helper
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: child,
          ),
        ),
      ),
    );
  }
}
