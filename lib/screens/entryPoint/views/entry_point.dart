import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/screens/client_pending_orders/views/client_pending_orders_screen.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/screens/home/views/home_page.dart';
import 'package:flutter_application_1/screens/profile/views/profile_screen.dart';
import 'package:flutter_application_1/screens/schedule/views/scheduled_shipments_screen.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late final PageController _pageController;

  final List<Widget> _pages = const [
    HomePage(),
    ClientPendingOrdersScreen(
      clientEmail: 't.p.tshabalala98@gmail.com',
    ),
    ScheduledShipmentsScreen(),
    Profile(email: 't.p.tshabalala98@gmail.com'),
  ];

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
          child: Scaffold(
            appBar: isHome ? const CustomAppBar() : null,

            drawer: Drawer(
              backgroundColor: Kolors.kPrimary,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration:
                        const BoxDecoration(color: Kolors.kPrimary),
                    child: Text(
                      'Plug Menu',
                      style: appStyle(
                        16,
                        Colors.white,
                        FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.done, color: Colors.white),
                    title: const Text(
                      'Complete Services',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      tabNotifier.setIndex(1);
                      _pageController.jumpToPage(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.contact_page,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Contacts',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      tabNotifier.setIndex(2);
                      _pageController.jumpToPage(2);
                    },
                  ),
                ],
              ),
            ),

            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Kolors.kPrimary,
                    Kolors.kSecondaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              /// ✅ FIX: Disable swipe ONLY on map screen
              child: PageView(
                controller: _pageController,
                physics: isHome
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                onPageChanged: tabNotifier.setIndex,
                children: _pages,
              ),
            ),

            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor:
                    const Color.fromARGB(255, 134, 165, 180),
              ),
              child: BottomNavigationBar(
                currentIndex: tabNotifier.index,
                onTap: (index) {
                  tabNotifier.setIndex(index);
                  _pageController.animateToPage(
                    index,
                    duration:
                        const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                },
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedItemColor: Kolors.kWhite,
                unselectedItemColor: Kolors.kDark,
                backgroundColor:
                    const Color.fromARGB(255, 131, 174, 196),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Ionicons.home_outline),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.pending_outlined),
                    label: "Pending",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    label: "Scheduled",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Ionicons.person_outline),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
