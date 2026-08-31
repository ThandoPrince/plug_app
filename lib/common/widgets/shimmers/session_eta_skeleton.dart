// lib/common/widgets/shimmers/session_eta_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/sessions/widgets/card_decoration.dart';


class SessionEtaSkeleton extends StatefulWidget {
  const SessionEtaSkeleton({super.key});

  @override
  State<SessionEtaSkeleton> createState() => _SessionEtaSkeletonState();
}

class _SessionEtaSkeletonState extends State<SessionEtaSkeleton>
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

  Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 5,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _skeletonMetric({
    required double iconWidth,
    required double valueWidth,
    required double labelWidth,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _skeletonBox(width: iconWidth, height: 24, radius: 6),
        const SizedBox(height: 8),
        _skeletonBox(width: valueWidth, height: 16, radius: 5),
        const SizedBox(height: 5),
        _skeletonBox(width: labelWidth, height: 10, radius: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _skeletonMetric(iconWidth: 24, valueWidth: 55, labelWidth: 55),
            Container(width: 1, height: 45, color: Colors.grey.shade200),
            _skeletonMetric(iconWidth: 24, valueWidth: 60, labelWidth: 40),
          ],
        ),
      ),
    );
  }
}