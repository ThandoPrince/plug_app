import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class TrackServiceSkeleton extends StatefulWidget {
  const TrackServiceSkeleton({super.key});

  @override
  State<TrackServiceSkeleton> createState() => _TrackServiceSkeletonState();
}

class _TrackServiceSkeletonState extends State<TrackServiceSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Kolors.kPrimary,
                Kolors.kPrimary,
                Kolors.kWhite,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Column(
              children: [
                // HANDLE
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ETA CARD
                _skeletonCard(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricSkeleton(),
                      _divider(),
                      _metricSkeleton(),
                      _divider(),
                      _metricSkeleton(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // PROVIDER CARD
                _skeletonCard(
                  height: 100,
                  child: Row(
                    children: [
                      _circleSkeleton(48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _lineSkeleton(140, 16),
                            const SizedBox(height: 8),
                            _lineSkeleton(100, 12),
                            const SizedBox(height: 7),
                            _lineSkeleton(120, 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SHIPMENT DETAILS
                _skeletonCard(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _lineSkeleton(150, 17),

                      const SizedBox(height: 18),

                      _lineSkeleton(
                        double.infinity,
                        13,
                      ),

                      const SizedBox(height: 10),

                      _lineSkeleton(
                        220,
                        13,
                      ),

                      const SizedBox(height: 10),

                      _lineSkeleton(
                        180,
                        13,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CONFIRM BUTTON
                _skeletonBox(
                  width: double.infinity,
                  height: 50,
                  radius: 12,
                ),

                const SizedBox(height: 16),

                // CANCEL BUTTON
                _skeletonBox(
                  width: double.infinity,
                  height: 50,
                  radius: 12,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 Widget _metricSkeleton() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      _skeletonBox(
        width: 22,
        height: 20,
        radius: 5,
      ),

      const SizedBox(height: 5),

      _skeletonBox(
        width: 55,
        height: 14,
        radius: 5,
      ),

      const SizedBox(height: 3),

      _skeletonBox(
        width: 45,
        height: 8,
        radius: 4,
      ),
    ],
  );
}

  Widget _divider() {
  return Container(
    width: 1,
    height: 42,
    color: Colors.grey.shade200,
  );
}

  Widget _skeletonCard({
    required double height,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _circleSkeleton(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _shimmerColor(),
      ),
    );
  }

  Widget _lineSkeleton(double width, double height) {
    return _skeletonBox(
      width: width,
      height: height,
      radius: 5,
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _shimmerColor(),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Color _shimmerColor() {
    final value = _controller.value;

    final intensity =
        (0.5 + (0.5 * (value < 0.5 ? value * 2 : (1 - value) * 2)));

    return Color.lerp(
      Colors.grey.shade200,
      Colors.grey.shade100,
      intensity,
    )!;
  }
}