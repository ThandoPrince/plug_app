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

  bool _hasNavigated = false;
  bool get hasNavigated => _hasNavigated;

  VoidCallback? onSessionCompleted;

  DateTime? _sessionStartTime;
  Duration _elapsed = Duration.zero;
  String get elapsedTimeFormatted => _formatDuration(_elapsed);

  bool _disposed = false;

  ClientSessionLocationPingController({this.sessionId});

  void markNavigated() => _hasNavigated = true;

  /// Initialize session using backend start time
  void initSession({
    required int id,
    DateTime? backendCheckinTime,
  }) {
    sessionId = id;

    // Use backend check-in timestamp as absolute start time
    if (backendCheckinTime != null) {
      _sessionStartTime = backendCheckinTime;
    }

    // Fetch initial ping
    fetchLatestPing();

    // Start UI elapsed timer
    _startElapsedTimer();

    // Start periodic ping fetch
    _startFetchingPing();
  }

  void _startElapsedTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      if (_sessionStartTime != null) {
        _elapsed = DateTime.now().difference(_sessionStartTime!);
        notifyListeners();
      }
    });
  }

  void _startFetchingPing() {
    if (sessionId == null) return;

    _fetchPingTimer?.cancel();

    _fetchPingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_disposed) return;
      await fetchLatestPing();
    });
  }

  Future<void> fetchLatestPing() async {
    if (sessionId == null || _disposed) return;

    try {
      latestPing = await ClientSessionLocationPingApi.fetchLatestPing(sessionId!);

      isInsideGeofence = latestPing?.insideGeofence ?? true;
      distanceMeters = latestPing?.distanceFromSiteMeters;

      // Optional: sync with backend duration if needed
      final backendDuration = latestPing?.session?.durationSeconds;
      if (backendDuration != null && _sessionStartTime == null) {
        _sessionStartTime = DateTime.now().subtract(Duration(seconds: backendDuration.toInt()));
      }

      if (!_disposed) notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Fetch latest ping error: $e");
      }
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
    _disposed = true;
    _timer?.cancel();
    _fetchPingTimer?.cancel();
    super.dispose();
  }
}
