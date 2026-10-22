// negotiation_sheet_skeleton.dart
import 'package:flutter/material.dart';

class NegotiationSheetSkeleton extends StatefulWidget {
  const NegotiationSheetSkeleton({super.key});

  @override
  State<NegotiationSheetSkeleton> createState() => _NegotiationSheetSkeletonState();
}

class _NegotiationSheetSkeletonState extends State<NegotiationSheetSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({required double width, required double height, required Alignment align}) {
    return Align(
      alignment: align,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Container(
            width: width,
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(-1 + t * 2, 0),
                end: Alignment(1 + t * 2, 0),
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _bar(width: 180, height: 44, align: Alignment.centerRight),
        _bar(width: 140, height: 60, align: Alignment.centerLeft),
        _bar(width: 200, height: 44, align: Alignment.centerRight),
        _bar(width: 120, height: 44, align: Alignment.centerLeft),
      ],
    );
  }
}