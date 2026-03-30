import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class BookingUtils {
  /// Handle permissions for camera or location
  static Future<bool> handlePermission({required bool isCamera}) async {
    PermissionStatus status = isCamera
        ? await Permission.camera.request()
        : await Permission.location.request();
    return status.isGranted;
  }

  /// Show date picker and return selected date
  static Future<DateTime?> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    return pickedDate;
  }
/// Show time picker and return selected time
static Future<TimeOfDay?> pickTime(BuildContext context) async {
  final now = DateTime.now();

  // Add 1 hour and 10 minutes
  final futureTime = now.add(const Duration(hours: 1, minutes: 10));

  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(futureTime),
  );

  return pickedTime;
}
}
