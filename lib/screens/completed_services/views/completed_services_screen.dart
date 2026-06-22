import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/completed_service_controller.dart';
import 'package:flutter_application_1/screens/completed_services/completed_services_details/views/completed_services_details_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClientRatingsScreen extends StatefulWidget {
  
  const ClientRatingsScreen({Key? key}) : super(key: key);

  @override
  State<ClientRatingsScreen> createState() => _ClientRatingsScreenState();
}

class _ClientRatingsScreenState extends State<ClientRatingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClientRatingsController>().fetchRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Service History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<ClientRatingsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (controller.ratings.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, kToolbarHeight + 40.h, 16.w, 20.h),
              itemCount: controller.ratings.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (_, index) {
                final rating = controller.ratings[index];
                final provider = rating.session?.shipment?.serviceOrdered?.providerForService?.provider;
                final serviceName = rating.session?.shipment?.serviceOrdered?.serviceRequired?.serviceName ?? "Service";
                final status = rating.session?.sessionStatus ?? "Completed";

                // Score Parsing
                int score = 0;
                if (rating.score != null) {
                  if (rating.score is int) score = rating.score as int;
                  else if (rating.score is String) score = int.tryParse(rating.score as String) ?? 0;
                }

                final providerImageUrl = provider?.profileImageUrl != null && provider!.profileImageUrl!.isNotEmpty;
                    
                   

                return _buildGlassListItem(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClientRatingDetailsScreen(rating: rating)),
                  ),
                  child: Row(
                    children: [
                      // Provider Avatar with border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Colors.white12,
                          backgroundImage: providerImageUrl != null ? NetworkImage(providerImageUrl.toString()) : null,
                          child: providerImageUrl == null ? Icon(Icons.person, color: Colors.white) : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Info Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  serviceName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Kolors.kDark),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            Text(
                              provider?.fullName ?? 'Unknown',
                              style: TextStyle(color: Colors.black38, fontSize: 13.sp),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 12.sp,
                                  color: i < score ? Colors.orangeAccent : Colors.white30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.white38),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassListItem({required Widget child, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: Kolors.kDark, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 60.sp, color: Colors.white38),
            SizedBox(height: 10.h),
            Text(
              "No services completed yet.",
              style: TextStyle(fontSize: 14.sp, color: Kolors.kDark.withOpacity(0.7)),
            ),
          ],
        ),
      );
}