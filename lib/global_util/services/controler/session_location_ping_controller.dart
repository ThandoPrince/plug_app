import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/sessions/session_location_ping_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_location_ping_model.dart';

class ClientSessionLocationPingController extends ChangeNotifier {
  int? sessionId;

  ClientSessionLocationPingModel? latestPing;
  bool isInsideGeofence = true;
  double? distanceMeters;

  Timer? _timer;
  Timer? _fetchPingTimer;

  Duration _elapsed = Duration.zero;
  String get elapsedTimeFormatted => _formatDuration(_elapsed);

  ClientSessionLocationPingController({this.sessionId});

  /// Initialize session using backend duration_seconds
  void initSession(int id, {double? backendDurationSeconds}) {
    sessionId = id;

    // Start elapsed from backend duration in seconds
    _elapsed = Duration(seconds: backendDurationSeconds?.toInt() ?? 0);

    _startElapsedTimer();
    _startFetchingPing();
  }

  void _startElapsedTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _startFetchingPing() {
    if (sessionId == null) return;
    _fetchPingTimer?.cancel();
    _fetchPingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await fetchLatestPing();
    });
  }

  Future<void> fetchLatestPing() async {
    if (sessionId == null) return;

    try {
      latestPing = await ClientSessionLocationPingApi.fetchLatestPing(sessionId!);
      isInsideGeofence = latestPing?.insideGeofence ?? true;
      distanceMeters = latestPing?.distanceFromSiteMeters;

      // Update elapsed if backend duration_seconds is higher than current
      final backendDuration = latestPing?.session?.durationSeconds;
      if (backendDuration != null && backendDuration > _elapsed.inSeconds) {
        _elapsed = Duration(seconds: backendDuration.toInt());
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("❌ Fetch latest ping error: $e");
    }
  }

  Future<void> endSession() async {
    _timer?.cancel();
    _fetchPingTimer?.cancel();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fetchPingTimer?.cancel();
    super.dispose();
  }
}
