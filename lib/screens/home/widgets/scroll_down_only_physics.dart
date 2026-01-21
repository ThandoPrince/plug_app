import 'package:flutter/widgets.dart';

/// ScrollPhysics that only allows scrolling down (positive offset),
/// prevents scrolling up beyond the top.
class ScrollDownOnlyPhysics extends ScrollPhysics {
  const ScrollDownOnlyPhysics({super.parent});

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ScrollDownOnlyPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Prevent scrolling up beyond the top
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels; // block upward
    }
    return 0.0; // allow downward
  }
}
