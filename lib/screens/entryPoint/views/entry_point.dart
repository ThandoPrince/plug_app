import 'dart:ui';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/const/services/registration/logout_api.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/logout_controller.dart';

import 'package:flutter_application_1/screens/completed_services/views/completed_services_screen.dart';
import 'package:flutter_application_1/screens/home/views/google_home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/screens/client_pending_orders/views/client_pending_orders_screen.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/screens/profile/views/profile_screen.dart';
import 'package:flutter_application_1/screens/schedule/views/scheduled_shipments_screen.dart';

// Import both map engine pages
import 'package:flutter_application_1/screens/home/views/home_page.dart'; // HERE Maps
// Google Maps

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late final PageController _pageController;
  bool _isHmsPresent = false;
  bool _checkingHardware = true;


 @override
void initState() {
  super.initState();

  _pageController = PageController();
  _checkHardwarePlatform();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final clientId = AuthSessionController.instance.clientId;

    if (clientId != null) {
      context
          .read<ClientProfileController>()
          .fetchClientByEmail(clientId);
    }
  });
}

  /// Evaluates device runtime to detect Huawei Mobile Services availability
  Future<void> _checkHardwarePlatform() async {
    try {
      // Replace with your preferred HMS check plugin code if available, e.g.:
      // final int result = await HmsApiAvailability().isHMSAvailable();
      // _isHmsPresent = (result == 0);

      // Fallback placeholder logic for runtime branching setup
      _isHmsPresent = false;
    } catch (_) {
      _isHmsPresent = false;
    } finally {
      if (mounted) {
        setState(() => _checkingHardware = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
  
    super.dispose();
  }

  void _goToPage(int index) {
  if (!_pageController.hasClients) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_pageController.hasClients) return;

    final current = _pageController.page?.round() ?? 0;
    if (current == index) return;

    _pageController.jumpToPage(index);
  });
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

  Future<void> _logout() async {
  final logoutController = LogoutController();

  try {
    Provider.of<TabIndexNotifier>(context, listen: false).reset();

    await logoutController.logout();

    if (!mounted) return;

    // Clear session AFTER API call (or inside API if you prefer)
    await AuthSessionController.instance.clearSession();

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

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionController>();
    final email = session.clientId;

    if (email == null || _checkingHardware) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Dynamic routing matrix selection based on device operating environment
    final List<Widget> pages = [
      const GoogleHomeMapPage(),
      const ClientPendingOrdersScreen(),
      const ScheduledShipmentsScreen(),
      const Profile(),
    ];

    return Consumer<TabIndexNotifier>(
      builder: (context, tabNotifier, _) {
        final bool isHome = tabNotifier.index == 0;

        return WillPopScope(
          onWillPop: () async {
            if (!isHome) {
              tabNotifier.setIndex(0);
              _pageController.jumpToPage(0);
              return false;
            }
            return true;
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: isHome ? CustomAppBar() : null,
              drawer: _buildDrawer(context, tabNotifier),
              body: PageView(
                controller: _pageController,
                physics: isHome
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                onPageChanged: (index) {
  tabNotifier.setIndex(index);
},
                children: pages,
              ),
              bottomNavigationBar: _buildBottomNav(tabNotifier),
            ),
          ),
        );
      },
    );
  }

  /// Drawer
 Widget _buildDrawer(BuildContext context, TabIndexNotifier tabNotifier) {
  return Consumer<ClientProfileController>(
    builder: (context, profileCtrl, _) {
      final profile = profileCtrl.clientProfile;

      return Drawer(
        backgroundColor: Kolors.kPrimary.withOpacity(0.95),
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              height: 200,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
                    ),
                  ),

                  SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: InkWell(
      onTap: () {
  Navigator.pop(context);
  _goToPage(3);
},
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white24,
              backgroundImage:
                  (profile?.profilePic?.isNotEmpty ?? false)
                      ? NetworkImage(profile!.profilePic!)
                      : null,
              child: (profile?.profilePic?.isEmpty ?? true)
                  ? const Icon(
                      Ionicons.person,
                      color: Colors.white,
                      size: 35,
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            Text(
              profile == null
                  ? "Loading..."
                  : "${profile.firstName ?? ''} ${profile.lastName ?? ''}"
                      .trim(),
              style: appStyle(18, Colors.white, FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              profile?.clientProfile?.emailAddress ?? "No email",
              style: appStyle(12, Colors.white70, FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  ),
)
                ],
              ),
            ),

            /// ================= MENU =================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [

                  // _buildDrawerTile(
                  //   icon: Icons.check_circle_outline,
                  //   title: 'Completed Services',
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => const ClientRatingsScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),

                  const Divider(color: Colors.white24),

                  _buildDrawerTile(
                    icon: Icons.history_rounded,
                    title: 'Service History',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientRatingsScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(color: Colors.white24),

                ],
              ),
            ),

            /// ================= FOOTER =================
            const Divider(color: Colors.white24, height: 1),

            _buildDrawerTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: _confirmLogout,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 10),

            const Text(
              "App Version 1.0.0",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: appStyle(14, color, FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }

  /// Glass Bottom Navigation
  Widget _buildBottomNav(TabIndexNotifier tabNotifier) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 4,
              activeColor: Kolors.kBlue,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              duration: const Duration(milliseconds: 350),
              tabBackgroundColor: Kolors.kPrimary.withOpacity(0.1),
              color: Kolors.kDark.withOpacity(0.6),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              tabs: const [
                GButton(icon: Ionicons.home_outline, text: 'Home'),
                GButton(icon: Icons.pending_outlined, text: 'Pending'),
                GButton(icon: Icons.calendar_month_outlined, text: 'Schedule'),
                GButton(icon: Ionicons.person_outline, text: 'Profile'),
              ],
              selectedIndex: _pageController.hasClients
    ? (_pageController.page?.round() ?? 0)
    : tabNotifier.index,
              onTabChange: (index) {
  _goToPage(index);
},
            ),
          ),
        ),
      ),
    );
  }
}
