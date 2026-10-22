import 'package:flutter/material.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';

class CommonErrorState extends StatelessWidget {
  final Future Function()? onRefresh;
  final String title;
  final String message;
  final IconData icon;

  const CommonErrorState({
    super.key,
    this.onRefresh,
    this.title = "Something went wrong",
    this.message = "Please try again later.",
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return _buildStateView(
      icon: icon,
      title: title,
      subtitle: message,
      onRefresh: onRefresh,
    );
  }

  Widget _buildStateView({
    required IconData icon,
    required String title,
    required String subtitle,
    Future Function()? onRefresh,
  }) {
    return RefreshIndicator(
      color: Kolors.kPrimary,
      backgroundColor: Colors.white,
      onRefresh: onRefresh ?? () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
