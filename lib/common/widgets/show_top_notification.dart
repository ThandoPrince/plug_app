import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showTopNotification(BuildContext context, String message, {bool isError = false}) {
  Flushbar(
    message: message,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: isError ? Colors.red : Colors.green,
    flushbarPosition: FlushbarPosition.TOP, // top of screen
    animationDuration: const Duration(milliseconds: 300),
  ).show(context);
}
