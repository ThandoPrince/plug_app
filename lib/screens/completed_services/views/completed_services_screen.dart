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

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    final uri = Uri.parse(baseUrl).resolve(path).toString();
    return NetworkImage(uri);
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
              floating: true,
              snap: true,
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
                return ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [ClientRatingsSkeleton()],
                );
              }

              if (controller.ratings.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 64.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "No Completed Services",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Kolors.kWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Once your services are completed, they will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Kolors.kWhite.withOpacity(0.75),
                            height: 1.4,
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
                  isLoading: false,
                  onRefresh: () async {
                    await controller.refresh();
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                    itemCount: controller.ratings.length + (showFooter ? 1 : 0),
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) {
                      if (index >= controller.ratings.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: controller.hasLoadMoreError
                                ? TextButton(
                                    onPressed: () =>
                                        controller.loadMore(retry: true),
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
                      final provider = rating
                          .session
                          ?.shipment
                          ?.serviceOrdered
                          ?.providerForService
                          ?.provider;

                      final serviceName = rating.session?.shipment?.serviceOrdered
                              ?.serviceRequired?.serviceName ??
                          "Service";

                      final orderId = rating.session?.shipment?.serviceOrdered
                              ?.orderId ??
                          "UNKNOWN";

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

                      final providerImageUrl =
                          _resolveImage(provider?.profileImageUrl);

                      return _buildCard(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientRatingDetailsScreen(rating: rating),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Kolors.kPrimary.withOpacity(0.2),
                                    width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 26.r,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: providerImageUrl,
                                child: provider?.profileImageUrl == null
                                    ? Icon(Icons.person,
                                        color: Kolors.kDark, size: 24.sp)
                                    : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          serviceName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp,
                                            color: Kolors.kDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      _buildStatusBadge(status),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    provider?.fullName ?? 'Unknown Provider',
                                    style: TextStyle(
                                      color: Kolors.kDark.withOpacity(0.6),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.tag,
                                        size: 11.sp,
                                        color: Kolors.kDark.withOpacity(0.4),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        orderId.toString(),
                                        style: TextStyle(
                                          color: Kolors.kDark.withOpacity(0.5),
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            Icons.star_rounded,
                                            size: 14.sp,
                                            color: i < score
                                                ? Colors.amber.shade700
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13.sp,
                              color: Kolors.kDark.withOpacity(0.3),
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
      ),
    );
  }

  Widget _buildCard({required Widget child, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Kolors.kOffWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Kolors.kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Kolors.kPrimary,
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}