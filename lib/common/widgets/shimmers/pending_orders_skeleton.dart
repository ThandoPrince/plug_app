// lib/screens/client_pending_orders/widgets/pending_orders_skeleton.dart
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

/// One placeholder card mimicking a pending-order list item.
class _PendingOrderCardSkeleton extends StatelessWidget {
  const _PendingOrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShimmerBox(
            width: 52,
            height: 52,
            borderRadius: BorderRadius.all(Radius.circular(14)),
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
                const SizedBox(height: 10),
                _ShimmerBox(
                  width: 140,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 10),
                _ShimmerBox(
                  width: 90,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder list shown while [ClientPendingOrdersController] is loading.
class PendingOrdersSkeleton extends StatelessWidget {
  final int itemCount;

  const PendingOrdersSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _PendingOrderCardSkeleton(),
    );
  }
}