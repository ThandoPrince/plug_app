import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_model.dart';
import 'package:provider/provider.dart';

class AccountSecurityScreen extends StatelessWidget {
  final ClientDetailModel profile;
  const AccountSecurityScreen({super.key,required this.profile,});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Delete Account?",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            "This action is permanent and cannot be undone. All your profile data, history, and active settings will be completely removed.",
            style: TextStyle(height: 1.4, color: Colors.black87),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Execute Account Deletion Logic via API
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete permanently"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Kolors.kDark;
    
    return Scaffold(
       backgroundColor: Kolors.kPrimary,
      appBar: AppBar(
  backgroundColor: Kolors.kPrimary,
  elevation: 0,
  centerTitle: true,
  iconTheme: const IconThemeData(
    color: Colors.white, // back button white
  ),
  title: const Text(
    "Account & Security",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
  ),
),
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _buildSettingTile(
                            icon: Icons.email_outlined,
                            themeColor: themeColor,
                            title: "Email Address",
                            subtitle: profile.clientProfile?.emailAddress ?? "Not Available",
                            onTap: () {
                              // Change Email Flow
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade100),
                          _buildSettingTile(
                            icon: Icons.phone_android_outlined,
                            themeColor: themeColor,
                            title: "Mobile Number",
                            subtitle: profile.clientProfile?.mobileNumber ?? "Not Available",
                            onTap: () {
                              // Change Phone Flow
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade100),
                          _buildSettingTile(
                            icon: Icons.lock_outline,
                            themeColor: themeColor,
                            title: "Change Password",
                            onTap: () {
                              // Change Password Flow
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Destructive Action Zone
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade600),
                  label: Text(
                    "Delete Account",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.red.shade50.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color themeColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: themeColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E1E24),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.3,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}