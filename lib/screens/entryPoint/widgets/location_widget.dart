import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:go_router/go_router.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      GoRouter.of(context).push('/location');// Use your route name here
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
          backgroundColor: Kolors.kOffWhite.withOpacity(.3),
          child: const Icon(
            Icons.location_on,
            size: 20,
            color: Kolors.kRed,
          ),
        ),
      ),
    );
  }
}
