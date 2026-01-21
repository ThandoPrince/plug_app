import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/home/widgets/here_map_view_home.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/screens/home/widgets/scroll_down_only_physics.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/global_util/services/widgets/services_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _refresh() async {
    final serviceCtrl = Provider.of<ServiceController>(context, listen: false);
    final mapCtrl = Provider.of<HereMapMarkerController>(context, listen: false);

    await serviceCtrl.fetchServices();

    if (mapCtrl.selectedServiceId != null) {
      await mapCtrl.showServiceProviders(mapCtrl.selectedServiceId!);
    }
  }

  /// --- Top Service Bar as a method ---
  Widget _buildAvailSerBar() {
    final serviceCtrl = Provider.of<ServiceController>(context);
    final mapCtrl = Provider.of<HereMapMarkerController>(context);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 10) {
          _refreshKey.currentState?.show();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔹 Important to avoid overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableText(
            text: "Active Service Providers",
            style: appStyle(14, Colors.black, FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (serviceCtrl.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (serviceCtrl.error != null)
            Text("Error: ${serviceCtrl.error}")
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: serviceCtrl.services.take(10).map((service) {
                  final isSelected = mapCtrl.selectedServiceId == service.serviceId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 100,
                      height: 60,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: ServicesIcons.fromServiceModel(
                            service: service,
                            isSelected: isSelected,
                            onTap: () {
                              if (isSelected) {
                                mapCtrl.clearSelection();
                                mapCtrl.removeSpMarkers();
                              } else {
                                mapCtrl.selectService(service.serviceId);
                                mapCtrl.showServiceProviders(service.serviceId);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push("/viewAllServices"),
            child: Center(
              child: ReusableText(
                text: "View All Available Services",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    final double availSerBarHeight = 160.h;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Top Service Bar with RefreshIndicator
            SizedBox(
              height: availSerBarHeight,
              child: SafeArea(
                child: RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const ScrollDownOnlyPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildAvailSerBar(),
                    ),
                  ),
                ),
              ),
            ),

            // Map fills remaining space
            Expanded(
              child: Consumer<HereMapMarkerController>(
                builder: (_, mapCtrl, __) {
                  return HereMapDemo(
                    key: const PageStorageKey('hereMap'),
                    email: "t.p.tshabalala98@gmail.com",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
