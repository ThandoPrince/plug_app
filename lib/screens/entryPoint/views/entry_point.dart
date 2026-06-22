import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';
import 'package:flutter_application_1/screens/completed_services/completed_services_details/views/completed_services_details_screen.dart';
import 'package:flutter_application_1/screens/completed_services/views/completed_services_screen.dart';
import 'package:flutter_application_1/screens/home/views/google_home_page.dart';
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
      _isHmsPresent ? const HomePage() : const GoogleHomeMapPage(),
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
                onPageChanged: tabNotifier.setIndex,
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
    return Drawer(
      backgroundColor: Kolors.kPrimary.withOpacity(0.95),
      child: Column(
        children: [
          Container(
            height: 200,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        height: 70,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Ionicons.person, size: 35, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          'The Plug Menu',
                          style: appStyle(18, Colors.white, FontWeight.bold),
                        ),
                        Text(
                          "My Plug",
                          style: appStyle(12, Colors.white70, FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Kolors.kPrimary.withOpacity(0.1),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
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
                      // Handled by client screen architecture routing parameters
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          _buildDrawerTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () {},
            color: Colors.redAccent,
          ),
          const SizedBox(height: 20),
        ],
      ),
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
              selectedIndex: tabNotifier.index,
              onTabChange: (index) {
                tabNotifier.setIndex(index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}