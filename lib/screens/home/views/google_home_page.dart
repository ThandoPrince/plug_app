import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/services_icons.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
import 'package:flutter_application_1/screens/home/widgets/scroll_down_only_physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';



class GoogleHomeMapPage extends StatefulWidget {
  const GoogleHomeMapPage({super.key});

  @override
  State<GoogleHomeMapPage> createState() => _GoogleHomeMapPageState();
}

class _GoogleHomeMapPageState extends State<GoogleHomeMapPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _refresh() async {
    final serviceCtrl = Provider.of<ServiceController>(context, listen: false);
    final mapCtrl = Provider.of<GoogleMapMarkerController>(context, listen: false);

    await serviceCtrl.fetchServices();
    await mapCtrl.showDefaultAddress();

    if (mapCtrl.selectedServiceId != null) {
      await mapCtrl.showServiceProviders(mapCtrl.selectedServiceId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            /// 🗺️ GOOGLE MAP INTERFACE LAYER
            Positioned.fill(
              child: Consumer<GoogleMapMarkerController>(
                builder: (_, mapCtrl, __) {
                  return GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    initialCameraPosition: const CameraPosition(
                      target: GoogleMapMarkerController.fallbackCenter,
                      zoom: 13,
                    ),
                    markers: mapCtrl.markers,
                    onMapCreated: (controller) => mapCtrl.onMapCreated(controller, context),
                  );
                },
              ),
            ),

            /// 🌁 BLURRED HEADER OVERLAY
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Kolors.kPrimary.withOpacity(0.75),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: RefreshIndicator(
                        key: _refreshKey,
                        onRefresh: _refresh,
                        child: SingleChildScrollView(
                          physics: const ScrollDownOnlyPhysics(),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                            child: _buildServiceBar(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 🎯 FLOATING ACTION LOCATION CONTROLLER
            Positioned(
              right: 16,
              bottom: 140,
              child: Consumer<GoogleMapMarkerController>(
                builder: (_, mapCtrl, __) {
                  return FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: mapCtrl.focusOnUserOrDefault,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBar() {
  final serviceCtrl = Provider.of<ServiceController>(context);
  final mapCtrl = Provider.of<GoogleMapMarkerController>(context);

  return GestureDetector(
    onVerticalDragUpdate: (details) {
      if (details.delta.dy > 10) {
        _refreshKey.currentState?.show();
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Center(
          child: Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ReusableText(
              text: "Active Service Providers",
              style: appStyle(
                13.sp,
                Colors.white,
                FontWeight.w700,
              ),
            ),

            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  "Live",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 12.h),

        if (serviceCtrl.isLoading)
          SizedBox(
            height: 76.h,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )

        else if (serviceCtrl.error != null)
          SizedBox(
            height: 76.h,
            child: Center(
              child: Text(
                "Error fetching services",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12.sp,
                ),
              ),
            ),
          )

        else
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: serviceCtrl.featuredServices.map((service) {
                  final isSelected =
                      mapCtrl.selectedServiceId == service.serviceId;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          mapCtrl.clearSelection();
                          mapCtrl.removeSpMarkers();
                        } else {
                          mapCtrl.selectService(service.serviceId);
                          mapCtrl.showServiceProviders(
                            service.serviceId,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 250,
                        ),
                        curve: Curves.easeInOut,
                        width: 94.w,
                        height: 76.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(16.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.15),
                                    blurRadius: 10,
                                    offset:
                                        const Offset(0, 4),
                                  )
                                ]
                              : [],
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: ServicesIcons.fromServiceModel(
                              service: service,
                              isSelected: isSelected,
                              onTap: null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        SizedBox(height: 12.h),

        InkWell(
          onTap: () => context.push("/viewAllServices"),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                ReusableText(
                  text: "View All Available Services",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11.sp,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}