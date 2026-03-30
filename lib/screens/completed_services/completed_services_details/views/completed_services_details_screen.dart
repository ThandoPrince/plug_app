import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_byemail_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/ratings_model.dart';
import 'package:flutter_application_1/screens/booking/views/MultiProviderBookingScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClientRatingDetailsScreen extends StatelessWidget {
  final RatingModel rating;
  const ClientRatingDetailsScreen({Key? key, required this.rating})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shipment = rating.session?.shipment;
    final order = shipment?.serviceOrdered;
    final provider = order?.providerForService?.provider;
    final service = order?.serviceRequired;

    final durationSec = rating.session?.durationSeconds ?? 0;
    final durationText = "${(durationSec / 60).floor()}m ${durationSec % 60}s";

    final checkinTime = rating.session?.checkinTime != null
        ? DateFormat('dd MMM yyyy – HH:mm')
            .format(DateTime.parse(rating.session!.checkinTime!.toString()))
        : 'N/A';

    final checkoutTime = rating.session?.checkoutTime != null
        ? DateFormat('dd MMM yyyy – HH:mm')
            .format(DateTime.parse(rating.session!.checkoutTime!.toString()))
        : 'N/A';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Service Receipt',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                // 1. Provider Info Card
                _buildGlassCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45.r,
                        backgroundColor: Colors.white24,
                        child: CircleAvatar(
                          radius: 42.r,
                          backgroundImage: NetworkImage(
                              provider?.profileImageUrl ?? ''),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        provider?.fullName ?? 'Unknown',
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Kolors.kDark),
                      ),
                      Text(
                        service?.serviceName?.toUpperCase() ?? '',
                        style: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            fontSize: 12.sp),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Divider(color: Colors.white.withOpacity(0.2)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat(
                              "Total Price", "R${order?.finalPrice ?? '0'}"),
                          _buildMiniStat("Duration", durationText),
                          _buildMiniStat("Rating", "${rating.score}/5"),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 15.h),

                // 2. Professional Time Card (No Coordinates)
                _buildGlassCard(
                  title: "Service Times",
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.calendar_today_outlined, "Check-in",
                          checkinTime),
                      _buildDetailRow(
                          Icons.access_time, "Check-out", checkoutTime),
                      _buildDetailRow(Icons.location_on_outlined, "Address",
                          order?.deliveryAddress?.formattedAddress ?? 'N/A'),
                    ],
                  ),
                ),

                SizedBox(height: 15.h),

                // 3. Review Section
                _buildGlassCard(
                  title: "Your Feedback",
                  child: Text(
                    rating.review?.isEmpty ?? true
                        ? "You didn't leave a written review."
                        : "\"${rating.review!}\"",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Kolors.kDark.withOpacity(0.9),
                        fontSize: 14.sp),
                  ),
                ),

                SizedBox(height: 30.h),

  // 4. Action Button
  ElevatedButton(
  onPressed: () async {
    final controller = context.read<CostOfServiceController>();

    final email = rating.session!.shipment!.serviceOrdered!
        .providerForService!.provider.spProfile.emailAddress;

    await controller.fetchCostsByEmailsAndService(
  [email],
  rating.session!.shipment!.serviceOrdered!.serviceRequired!.serviceId,
);

    

    final costOfService = controller.costs;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProviderBookingScreen(
          serviceId: rating.session!.shipment!.serviceOrdered!
              .serviceRequired!.serviceId,
          selectedProviders: rating.session!.shipment!.serviceOrdered!
                      .providerForService !=
                  null
              ? [
                  rating.session!.shipment!.serviceOrdered!
                      .providerForService!.provider
                ]
              : [],
          selectedCosts: costOfService,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Kolors.kPrimary,
    foregroundColor: Kolors.kWhite,
    minimumSize: Size(double.infinity, 50.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.r),
    ),
    elevation: 0,
  ),
  child: Text(
    "Book ${provider?.fullName?.split(' ')[0]} Again",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.sp,
    ),
  ),
),

  SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                  color: Kolors.kDark,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Kolors.kDark)),
        Text(label, style: TextStyle(color: Colors.black38, fontSize: 11.sp)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black38, size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.black38, fontSize: 11.sp)),
                Text(value,
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: Kolors.kDark,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
