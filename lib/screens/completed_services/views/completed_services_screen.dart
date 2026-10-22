import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/shimmers/client_ratings_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/completed_service_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/refresh_indicator_widget.dart';
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

bool _onScroll(ScrollNotification n) {
  // Only the vertical list, not the NestedScrollView header.
  if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;

  if (n.metrics.extentAfter < 300) {
    final c = context.read<ClientRatingsController>();
    if (!c.hasLoadMoreError) c.loadMore();
  }
  return false;
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
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,   // shows immediately on scroll-up, doesn't wait to reach top
            snap: true,       // completes the show/hide animation once triggered
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Service History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        body: Consumer<ClientRatingsController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.ratings.isEmpty) {
  return const ClientRatingsSkeleton();
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

            final showFooter = controller.hasMore || controller.isLoadingMore;

return NotificationListener<ScrollNotification>(
  onNotification: _onScroll,
  child: GenericLoadingRefresh(
    isLoading: false, // the RefreshIndicator shows its own spinner
    onRefresh: () async {
      await controller.refresh();
    },
    child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      itemCount: controller.ratings.length + (showFooter ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (_, index) {
        if (index >= controller.ratings.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: controller.hasLoadMoreError
                  ? TextButton(
                      onPressed: () => controller.loadMore(retry: true),
                      child: const Text(
                        "Couldn't load more. Tap to retry",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
            ),
          );
        }

        final rating = controller.ratings[index];
                    final provider = rating.session?.shipment?.serviceOrdered
                        ?.providerForService?.provider;
              
                    final serviceName =
                        rating.session?.shipment?.serviceOrdered?.serviceRequired
                ?.serviceName ??
                "Service";
              
                final orderId =
                        rating.session?.shipment?.serviceOrdered?.orderId ?? "UNKNOWN";
              
              
                    final status =
                        rating.session?.sessionStatus ?? "UNKNOWN";
              
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
              
              SizedBox(height: 3.h),
              
              Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 11.sp,
                    color: Colors.black38,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    orderId.toString(),
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
              ),
            );
          },
        ),
      ),
  ));
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