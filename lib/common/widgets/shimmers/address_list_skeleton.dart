// lib/common/widgets/shimmers/address_list_skeleton.dart
import 'package:flutter/material.dart';

class AddressListSkeleton extends StatefulWidget {
  final int itemCount;

  const AddressListSkeleton({super.key, this.itemCount = 4});

  @override
  State<AddressListSkeleton> createState() => _AddressListSkeletonState();
}

class _AddressListSkeletonState extends State<AddressListSkeleton>
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.itemCount,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _AddressCardSkeleton(opacity: _opacity),
      ),
    );
  }
}

class _AddressCardSkeleton extends StatelessWidget {
  final Animation<double> opacity;

  const _AddressCardSkeleton({required this.opacity});

  BoxDecoration _bar({double? width, double height = 14}) {
    return BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: opacity,
      builder: (context, child) => Opacity(
        opacity: opacity.value,
        child: child,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon slot (matches Icons.home_filled / location_on)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),

              // Title + subtitle block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address title line (2-line max in real UI)
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: _bar(),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 14,
                      width: 140,
                      decoration: _bar(),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle row: "Primary • Country" + verification badge
                    Row(
                      children: [
                        Container(
                          height: 11,
                          width: 90,
                          decoration: _bar(),
                        ),
                        const Spacer(),
                        Container(
                          height: 20,
                          width: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Trailing check/radio icon slot
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
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