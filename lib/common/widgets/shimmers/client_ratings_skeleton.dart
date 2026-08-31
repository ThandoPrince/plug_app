// lib/common/widgets/shimmers/client_ratings_skeleton.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientRatingsSkeleton extends StatefulWidget {
  final int itemCount;

  const ClientRatingsSkeleton({super.key, this.itemCount = 6});

  @override
  State<ClientRatingsSkeleton> createState() => _ClientRatingsSkeletonState();
}

class _ClientRatingsSkeletonState extends State<ClientRatingsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, kToolbarHeight + 40.h, 16.w, 20.h),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => _RatingCardSkeleton(opacity: _opacity),
    );
  }
}

class _RatingCardSkeleton extends StatelessWidget {
  final Animation<double> opacity;

  const _RatingCardSkeleton({required this.opacity});

  BoxDecoration _bar() => BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(6),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: opacity,
      builder: (context, child) => Opacity(
        opacity: opacity.value,
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // service name + status badge row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 14.h, width: 110.w, decoration: _bar()),
                          Container(
                            height: 16.h,
                            width: 54.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // provider name line
                      Container(height: 12.h, width: 90.w, decoration: _bar()),
                      SizedBox(height: 6.h),

                      // order id line
                      Container(height: 10.h, width: 60.w, decoration: _bar()),
                      SizedBox(height: 6.h),

                      // star rating row
                      Row(
                        children: List.generate(
                          5,
                          (i) => Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: Container(
                              width: 12.sp,
                              height: 12.sp,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),
                Container(
                  width: 14.sp,
                  height: 14.sp,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}