import 'package:flutter/material.dart';

BoxDecoration cardDecoration({
  Color? color,
  double borderRadius = 20,
  List<BoxShadow>? boxShadow,
}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
  );
}
