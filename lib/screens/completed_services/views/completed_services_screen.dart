import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/completed_service_controller.dart';
import 'package:flutter_application_1/screens/completed_services/completed_services_details/views/completed_services_details_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final controller = context.read<ClientRatingsController>();

    // prevent duplicate fetch
    if (controller.ratings.isEmpty && !controller.isLoading) {
      controller.fetchRatings();
    }
  });
}

  ImageProvider _resolveImage(String? path) {
  final baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

  if (path == null || path.isEmpty) {
    return const AssetImage('assets/default_profile.png');
  }

  // already absolute URL → use directly
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }

  // relative path → safely join
  final uri = Uri.parse(baseUrl).resolve(path).toString();
  return NetworkImage(uri);
}
  @override
  void dispose() {
    
    super.dispose();
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
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        ),
        child: Consumer<ClientRatingsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (controller.ratings.isEmpty) {
  return ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 120),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Completed Services",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Kolors.kWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Once your services are completed, they will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Kolors.kWhite.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ],
  );
}

            return RefreshIndicator(
  onRefresh: () async {
    await controller.refresh();
  },
  color: Colors.white,
  backgroundColor: Kolors.kPrimary,
  child: ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(
      16.w,
      kToolbarHeight + 40.h,
      16.w,
      20.h,
    ),
    itemCount: controller.ratings.length,
    separatorBuilder: (context, index) => SizedBox(height: 12.h),
    itemBuilder: (_, index) {
      final rating = controller.ratings[index];
      final provider = rating.session?.shipment?.serviceOrdered
          ?.providerForService?.provider;

      final serviceName =
          rating.session?.shipment?.serviceOrdered?.serviceRequired
              ?.serviceName ??
              "Service";

      final status =
          rating.session?.sessionStatus ?? "Completed";

      int score = 0;
      if (rating.score != null) {
        if (rating.score is int) {
          score = rating.score as int;
        } else if (rating.score is String) {
          score = int.tryParse(rating.score as String) ?? 0;
        }
      }

      final providerImageUrl = _resolveImage(provider?.profileImageUrl);

      return _buildGlassListItem(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientRatingDetailsScreen(rating: rating),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.white12,
                backgroundImage: providerImageUrl,
                child: provider?.profileImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Kolors.kDark,
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  Text(
                    provider?.fullName ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        size: 12.sp,
                        color: i < score
                            ? Colors.orangeAccent
                            : Colors.white30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.white38,
            ),
          ],
        ),
      );
    },
  ),
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