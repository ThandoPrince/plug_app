// lib/screens/profile/widgets/profile_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
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

    _opacity = Tween<double>(begin: 0.35, end: 0.85).animate(
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
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_opacity.value),
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

class _GlassCardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassCardShell({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: child,
    );
  }
}

/// Placeholder shown while [ClientProfileController] / [AddressClientCtrl]
/// are loading. Mirrors the real Profile layout so there's no layout jump.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // Avatar + name + email
            _ShimmerBox(
              width: 120.r,
              height: 120.r,
              borderRadius: BorderRadius.circular(60.r),
            ),
            SizedBox(height: 14.h),
            _ShimmerBox(
              width: 140.w,
              height: 18.h,
              borderRadius: BorderRadius.circular(6.r),
            ),
            SizedBox(height: 8.h),
            _ShimmerBox(
              width: 180.w,
              height: 13.h,
              borderRadius: BorderRadius.circular(6.r),
            ),

            SizedBox(height: 25.h),

            // Stats card
            _GlassCardShell(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statPlaceholder(),
                  Container(height: 32.h, width: 1, color: Colors.white24),
                  _statPlaceholder(),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // Info card (Name / DOB rows)
            _GlassCardShell(
              child: Column(
                children: [
                  _infoRowPlaceholder(),
                  Divider(color: Colors.white.withOpacity(0.15), height: 22.h),
                  _infoRowPlaceholder(),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // Action tiles
            _actionTilePlaceholder(),
            _actionTilePlaceholder(),
            _actionTilePlaceholder(),
            _actionTilePlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _statPlaceholder() {
    return Column(
      children: [
        _ShimmerBox(
          width: 32.w,
          height: 20.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        SizedBox(height: 6.h),
        _ShimmerBox(
          width: 44.w,
          height: 11.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
    );
  }

  Widget _infoRowPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _ShimmerBox(
            width: 34.w,
            height: 34.w,
            borderRadius: BorderRadius.circular(17.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: 70.w,
                  height: 10.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                SizedBox(height: 6.h),
                _ShimmerBox(
                  width: 130.w,
                  height: 14.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTilePlaceholder() {
    return _GlassCardShell(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          _ShimmerBox(
            width: 34.w,
            height: 34.w,
            borderRadius: BorderRadius.circular(17.r),
          ),
          SizedBox(width: 14.w),
          _ShimmerBox(
            width: 120.w,
            height: 14.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}