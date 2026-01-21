import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionCtrl extends ChangeNotifier {
  bool _granted = false;

  bool get granted => _granted;

  Future<void> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    _granted = status.isGranted;
    notifyListeners();
  }
}
