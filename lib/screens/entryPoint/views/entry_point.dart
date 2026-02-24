import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/screens/client_pending_orders/views/client_pending_orders_screen.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/screens/home/views/home_page.dart';
import 'package:flutter_application_1/screens/profile/views/profile_screen.dart';
import 'package:flutter_application_1/screens/schedule/views/scheduled_shipments_screen.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionController>();
    final email = session.email;

    if (email == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      const HomePage(),
      ClientPendingOrdersScreen(clientEmail: email),
      const ScheduledShipmentsScreen(),
      Profile(email: email),
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
                colors: [Kolors.kPrimary,Kolors.kPrimary, Kolors.kSecondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: isHome ? const CustomAppBar() : null,
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
      backgroundColor: Kolors.kPrimary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Kolors.kPrimary),
            child: Text(
              'Plug Menu',
              style: appStyle(16, Colors.white, FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.done, color: Colors.white),
            title: const Text('Complete Services',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              tabNotifier.setIndex(1);
              _pageController.jumpToPage(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_page, color: Colors.white),
            title:
                const Text('Contacts', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              tabNotifier.setIndex(2);
              _pageController.jumpToPage(2);
            },
          ),
        ],
      ),
    );
  }

  /// Glass Bottom Navigation
  Widget _buildBottomNav(TabIndexNotifier tabNotifier) {
  return ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.transparent, // Make container fully transparent
        child: SafeArea(
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 4,
            activeColor: Kolors.kBlue,
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            duration: const Duration(milliseconds: 350),
            tabBackgroundColor: Kolors.kPrimary.withOpacity(0.1), // subtle glass
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
