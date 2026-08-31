// lib/common/widgets/shimmers/provider_list_skeleton.dart
import 'package:flutter/material.dart';

class ProviderListSkeleton extends StatefulWidget {
  final int itemCount;

  const ProviderListSkeleton({super.key, this.itemCount = 5});

  @override
  State<ProviderListSkeleton> createState() => _ProviderListSkeletonState();
}

class _ProviderListSkeletonState extends State<ProviderListSkeleton>
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => _ProviderCardSkeleton(opacity: _opacity),
    );
  }
}

class _ProviderCardSkeleton extends StatelessWidget {
  final Animation<double> opacity;

  const _ProviderCardSkeleton({required this.opacity});

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Checkbox slot
              SizedBox(
                width: 40,
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Profile image circle (matches 58x58)
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 14),

              // Name + rating/status + description block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 15, width: 130, decoration: _bar()),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(height: 12, width: 40, decoration: _bar()),
                        const SizedBox(width: 10),
                        Container(height: 12, width: 60, decoration: _bar()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 11, width: double.infinity, decoration: _bar()),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chevron circle slot
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}