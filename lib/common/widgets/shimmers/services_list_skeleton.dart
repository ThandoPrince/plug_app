// lib/common/widgets/shimmers/services_list_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class ServicesListSkeleton extends StatefulWidget {
  final int itemCount;

  const ServicesListSkeleton({super.key, this.itemCount = 6});

  @override
  State<ServicesListSkeleton> createState() => _ServicesListSkeletonState();
}

class _ServicesListSkeletonState extends State<ServicesListSkeleton>
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
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _ServiceCardSkeleton(opacity: _opacity),
      ),
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  final Animation<double> opacity;

  const _ServiceCardSkeleton({required this.opacity});

  BoxDecoration _bar() => BoxDecoration(
        color: Colors.grey.shade300,
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
      child: Container(
        decoration: BoxDecoration(
          color: Kolors.kOffWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Title + subtitle block (matches ListTile title/subtitle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 150,
                      decoration: _bar(),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 90,
                      decoration: _bar(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Trailing chevron slot
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}