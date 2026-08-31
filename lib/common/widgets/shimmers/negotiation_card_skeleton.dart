import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class NegotiationCardSkeleton extends StatefulWidget {
  const NegotiationCardSkeleton({super.key});

  @override
  State<NegotiationCardSkeleton> createState() =>
      _NegotiationCardSkeletonState();
}

class _NegotiationCardSkeletonState
    extends State<NegotiationCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: Colors.white.withOpacity(0.95),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // PROFILE IMAGE
                _shimmer(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                ),

                const SizedBox(width: 12),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmer(
                        width: 140,
                        height: 16,
                        borderRadius: BorderRadius.circular(5),
                      ),

                      const SizedBox(height: 8),

                      _shimmer(
                        width: 110,
                        height: 13,
                        borderRadius: BorderRadius.circular(4),
                      ),

                      const SizedBox(height: 7),

                      _shimmer(
                        width: 130,
                        height: 13,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // DATE
                _shimmer(
                  width: 70,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmer({
    required double width,
    required double height,
    required BorderRadius borderRadius,
  }) {
    final value = _animationController.value;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment(-1 + (value * 2), 0),
          end: Alignment(1 + (value * 2), 0),
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
        ),
      ),
    );
  }
}