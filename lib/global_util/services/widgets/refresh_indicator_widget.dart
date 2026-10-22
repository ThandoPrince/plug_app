import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class GenericLoadingRefresh extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final Widget child;

  const GenericLoadingRefresh({
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
        child: CircularProgressIndicator(
          color: Kolors.kPrimary,
        ),
      );
    }

    // Refreshable content
    if (onRefresh != null) {
      return RefreshIndicator(
          color: Kolors.kPrimary,
      backgroundColor: Colors.white,
        onRefresh: onRefresh!,
        child: child,
      );
    }

    // Normal content
    return child;
  }
}

