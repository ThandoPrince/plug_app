// lib/screens/schedule/widgets/shipment_list_skeleton.dart
import 'package:flutter/material.dart';

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
          color: Colors.white.withOpacity(_opacity.value * 0.9),
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// One placeholder card mimicking a shipment schedule card.
class _ShipmentCardSkeleton extends StatelessWidget {
  const _ShipmentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ShimmerBox(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    _ShimmerBox(
                      width: 100,
                      height: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
              _ShimmerBox(
                width: 60,
                height: 22,
                borderRadius: BorderRadius.circular(30),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ShimmerBox(
            width: double.infinity,
            height: 1,
            borderRadius: BorderRadius.circular(1),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShimmerBox(
                width: 90,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              _ShimmerBox(
                width: 70,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Placeholder list shown while [ShipmentController] is loading.
class ShipmentListSkeleton extends StatelessWidget {
  final int itemCount;

  const ShipmentListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (_, __) => const _ShipmentCardSkeleton(),
    );
  }
}