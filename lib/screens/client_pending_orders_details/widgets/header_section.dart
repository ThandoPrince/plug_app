import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class HeaderSection extends StatelessWidget {
  final String title;
  final String? status;

  const HeaderSection({super.key, required this.title, this.status});

 

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Kolors.kDark ;
   

    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
        // Optional: add a Status Badge here using statusColor
      ],
    );
  }
}
