// lib/common/widgets/shimmers/order_body_skeleton.dart
import 'package:flutter/material.dart';

class OrderBodySkeleton extends StatefulWidget {
  const OrderBodySkeleton({super.key});

  @override
  State<OrderBodySkeleton> createState() => _OrderBodySkeletonState();
}

class _OrderBodySkeletonState extends State<OrderBodySkeleton>
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

  BoxDecoration _bar() => BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  Widget _labelValueRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(height: 12, width: 90, decoration: _bar()),
            Container(height: 12, width: 120, decoration: _bar()),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: child,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- HeaderSection: title + status ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 18, width: 160, decoration: _bar()),
                  Container(
                    height: 22,
                    width: 74,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---- RequestDetailsCard ----
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 130, decoration: _bar()),
                    const SizedBox(height: 12),
                    _labelValueRow(),
                    _labelValueRow(),
                    _labelValueRow(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- DeliveryAddressCard ----
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 150, decoration: _bar()),
                    const SizedBox(height: 12),
                    Container(
                        height: 12,
                        width: double.infinity,
                        decoration: _bar()),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 200, decoration: _bar()),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- NotesCard (optional) ----
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 80, decoration: _bar()),
                    const SizedBox(height: 12),
                    Container(
                        height: 12,
                        width: double.infinity,
                        decoration: _bar()),
                    const SizedBox(height: 8),
                    Container(
                        height: 12,
                        width: double.infinity,
                        decoration: _bar()),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- ServiceImages (optional) ----
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, __) => Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}