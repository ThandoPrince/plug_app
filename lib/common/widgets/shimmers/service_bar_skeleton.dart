// lib/screens/home/widgets/service_bar_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single pulsing placeholder box, sized to match a service icon tile.
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
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_opacity.value * 0.25),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Placeholder row mimicking the featured-services icon strip while
/// [ServiceController] is loading. Sizes match the real tiles
/// (94.w x 76.h) so there's no layout jump when real content swaps in.
class ServiceBarSkeleton extends StatelessWidget {
  final int itemCount;

  const ServiceBarSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, __) {
          return _ShimmerBox(
            width: 94.w,
            height: 76.h,
            borderRadius: BorderRadius.circular(16.r),
          );
        },
      ),
    );
  }
}