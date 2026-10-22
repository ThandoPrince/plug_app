import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/shimmers/service_bar_skeleton.dart';

class HomeLoadingRefresh extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final Widget child;

  const HomeLoadingRefresh({
    super.key,
    required this.isLoading,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Initial loading
    if (isLoading) {
      return const Center(
        child: ServiceBarSkeleton(),
      );
    }

    // Refreshable content
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: Kolors.kPrimary,
        child: child,
      );
    }

    // Normal content
    return child;
  }
}