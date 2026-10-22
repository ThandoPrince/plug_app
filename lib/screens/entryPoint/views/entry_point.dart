import 'dart:async';
import 'dart:ui';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/badge_sync.dart';
import 'package:flutter_application_1/global_util/services/controler/client_order_realtime_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';

import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/logout_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/order_updates_badge_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/device_capability_controller.dart';

import 'package:flutter_application_1/screens/completed_services/views/completed_services_screen.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/tab_lifecycle_controller.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/entry_point_network_check.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/entry_point_retry.dart';
import 'package:flutter_application_1/screens/entryPoint/views/offline_home_screen.dart';
import 'package:flutter_application_1/screens/home/views/google_home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

// Google Maps

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> with WidgetsBindingObserver {
  late final PageController _pageController;
  bool _isHmsPresent = false;
    bool _noConnection = false;
  bool _checkingHardware = true;
  late final TabIndexNotifier _tabNotifier;
  MapServiceType? _mapServiceType;
    bool _isOffline = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _checkHardwarePlatform();

    _tabNotifier = context.read<TabIndexNotifier>();
    _tabNotifier.addListener(_onExternalTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchAllTabData();
      _goToPage(_tabNotifier.index);
    });
  }

  void _onExternalTabChange() {
    _goToPage(_tabNotifier.index);
  }

Future<void> _prefetchAllTabData() async {
  final clientId = AuthSessionController.instance.clientId;
  if (clientId == null) return;

    final connected = await hasNetworkConnection();
  if (!connected) {
    if (!mounted) return;
    setState(() {
      _noConnection = true;
      _isOffline = false;
      _isRetrying = false;
    });
    return; // don't even attempt the calls — there's nothing to retry
  }

  AuthSessionController.instance.setLoggedIn(true);

  final numericUserId = clientId; // confirm this is the numeric user id, not email
  final clientRealtime = context.read<ClientOrderRealtimeController>();
  final badgeCtrl = context.read<OrderUpdatesBadgeController>();
  final negotiationBadgeCtrl = context.read<NegotiationBadgeStore>();

  clientRealtime.onNegotiationRoundReceived = (negotiationId, orderId, round) {
  context.read<ClientPendingOrdersController>().refreshSilently();
  if (round.id != null) {
    negotiationBadgeCtrl.registerRound(
      negotiationId: negotiationId,
      roundId: round.id!,
      senderType: round.senderType,
      orderId: orderId,
    );
  }
};

  clientRealtime.onNegotiationStatusChanged = (negotiationId, orderId) {
    if (kDebugMode) {
      print('Status changed for negotiation $negotiationId, order $orderId — refreshing pending orders and shipments');
    }
    context.read<ClientPendingOrdersController>().refreshSilently();
    context.read<ShipmentController>().refreshSilently();
    if (orderId != null) badgeCtrl.increment(orderId);
  };

  clientRealtime.onShipmentStatusUpdated = (data) {
    if (kDebugMode) {
      print('Shipment status changed — refreshing shipments');
    }
    context.read<ShipmentController>().refreshSilently();
  };

  clientRealtime.connect(numericUserId);

  final profileCtrl = context.read<ClientProfileController>();
  final mapCtrl = context.read<GoogleMapMarkerController>();
  final serviceCtrl = context.read<ServiceController>();

  final pendingOrdersCtrl = context.read<ClientPendingOrdersController>();
  final shipmentCtrl = context.read<ShipmentController>();
  final tabLifecycle = context.read<TabLifecycleController>();
  final addressCtrl = context.read<AddressClientCtrl>();

try {
  await Future.wait([
    retryWithBackoff(() => profileCtrl.fetchClientByEmail(clientId), label: 'profile'),
    retryWithBackoff(() => serviceCtrl.fetchServices(), label: 'services'),
    retryWithBackoff(() => mapCtrl.showDefaultAddress(), label: 'defaultAddress'),
    retryWithBackoff(() => pendingOrdersCtrl.fetchPendingOrders(), label: 'pendingOrders'),
    retryWithBackoff(() => shipmentCtrl.fetchShipmentsByClientEmail(), label: 'shipments'),
    retryWithBackoff(() => addressCtrl.fetchAddresses(), label: 'addresses'),
  ]);

  if (!mounted) return;

  if (_isOffline) {
    setState(() {
      _isOffline = false;
      _isRetrying = false;
    });
  }

  unawaited(syncUnreadBadges(pendingOrdersCtrl, negotiationBadgeCtrl));

  tabLifecycle.markLoaded(3);
} catch (e) {
  if (kDebugMode) {
    print("EntryPoint prefetch failed after retries: $e");
  }
  if (!mounted) return;
  setState(() {
    _isOffline = true;
    _isRetrying = false;
  });
}
}

  Future<void> _checkHardwarePlatform() async {
    try {
      final deviceController = DeviceCapabilityController.instance;
      _mapServiceType = await deviceController.checkMapServiceAvailability();
      _isHmsPresent = _mapServiceType == MapServiceType.huawei;
    } catch (_) {
      _isHmsPresent = false;
      _mapServiceType = MapServiceType.google; // Default to Google on error
    } finally {
      if (mounted) {
        setState(() => _checkingHardware = false);
      }
    }
  }

    @override
  void dispose() {
    _tabNotifier.removeListener(_onExternalTabChange);
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


void _confirmLogout() {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
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
      title: const Text(
        'Logout?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'Are you sure you want to logout of your account?',
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1.4,
          color: Colors.black87,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      actions: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Kolors.kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
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
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



  Future<void> _logout() async {
    final logoutController = LogoutController();

    try {
      Provider.of<TabIndexNotifier>(context, listen: false).reset();
      context.read<ClientOrderRealtimeController>().disconnect();

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
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _prefetchAllTabData(); // reconnects socket + refetches
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

 if (_isOffline) {
    return OfflineHomeScreen(
      isRetrying: _isRetrying,
      onRetry: () {
        setState(() => _isRetrying = true);
        _prefetchAllTabData();
      },
    );
  }

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
              colors: [Kolors.kPrimary, Kolors.kPrimary],
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
            // tabNotifier.index is the single source of truth — it's kept
            // in sync with the PageView both ways (onPageChanged -> setIndex,
            // and the external listener -> _goToPage), so there's no need
            // to also read _pageController.page here. Doing so previously
            // caused the nav highlight to go stale: jumpToPage moves the
            // actual page content at the render layer without necessarily
            // triggering a fresh notifyListeners() (setIndex short-circuits
            // when the index is already correct), so this widget never
            // rebuilt to pick up the new page.
            selectedIndex: tabNotifier.index,
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