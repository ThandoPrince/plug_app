import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';

/// Enum representing the map service available on the device
enum MapServiceType {
  /// Google Mobile Services - Google Maps available
  google,
  /// Huawei Mobile Services - Google Maps NOT available
  huawei,
  /// Unknown - detection failed or not yet run
  unknown,
}

/// Controller for detecting device capabilities at runtime
/// Specifically checks for Google Mobile Services (GMS) availability
class DeviceCapabilityController extends ChangeNotifier {
  static DeviceCapabilityController? _instance;

  /// Singleton instance
  static DeviceCapabilityController get instance {
    _instance ??= DeviceCapabilityController._();
    return _instance!;
  }

  DeviceCapabilityController._();

  MapServiceType _mapServiceType = MapServiceType.unknown;
  bool _isChecking = false;
  String? _errorMessage;

  /// The type of map service available on this device
  MapServiceType get mapServiceType => _mapServiceType;

  /// Whether we're currently checking for GMS/HMS
  bool get isChecking => _isChecking;

  /// Whether Google Maps can be used (GMS available)
  bool get isGoogleMapsAvailable => _mapServiceType == MapServiceType.google;

  /// Whether we're on a Huawei device without GMS
  bool get isHuaweiWithoutGms => _mapServiceType == MapServiceType.huawei;

  /// Any error message from the detection process
  String? get errorMessage => _errorMessage;

  /// Whether detection has completed
  bool get hasCompleted => _mapServiceType != MapServiceType.unknown;

  /// Check if Google Mobile Services are available
  /// Uses huawei_hmsavailability to detect HMS vs GMS at runtime
  Future<MapServiceType> checkMapServiceAvailability() async {
    if (_isChecking) return _mapServiceType;

    _isChecking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if we're on Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        final int availability = await HmsApiAvailability()
            .isHMSAvailable()
            .timeout(const Duration(seconds: 3));

        if (availability == 0) {
          _mapServiceType = MapServiceType.huawei;
          debugPrint('DeviceCapabilityController: HMS detected (status 0)');
        } else {
          _mapServiceType = MapServiceType.google;
          debugPrint(
              'DeviceCapabilityController: HMS not available (status $availability), using GMS');
        }
      } else {
        // iOS and other platforms use Google Maps
        _mapServiceType = MapServiceType.google;
        debugPrint('DeviceCapabilityController: GMS available (iOS/other)');
      }
    } on PlatformException catch (e) {
      _errorMessage = 'Platform error checking HMS: ${e.message}';
      debugPrint('DeviceCapabilityController: $_errorMessage');
      // Fall back to fallback map on error rather than assuming GMS,
      // since a failed HMS check is itself evidence GMS may be absent.
      _mapServiceType = MapServiceType.huawei;
    } catch (e) {
      _errorMessage = 'Error checking HMS availability: $e';
      debugPrint('DeviceCapabilityController: $_errorMessage');
      _mapServiceType = MapServiceType.huawei;
    } finally {
      _isChecking = false;
      notifyListeners();
    }

    return _mapServiceType;
  }

  /// Force re-check (useful for testing)
  Future<MapServiceType> recheck() async {
    _mapServiceType = MapServiceType.unknown;
    return checkMapServiceAvailability();
  }

  /// Get a user-friendly description of the map service
  String get mapServiceDescription {
    switch (_mapServiceType) {
      case MapServiceType.google:
        return 'Google Maps (GMS)';
      case MapServiceType.huawei:
        return 'Huawei Map Kit (HMS)';
      case MapServiceType.unknown:
        return 'Detecting...';
    }
  }
}