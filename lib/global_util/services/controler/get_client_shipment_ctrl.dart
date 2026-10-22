import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/const/services/booking_services/client_shipment_api.dart';
import 'package:flutter_application_1/const/services/sessions/session_by_shipment_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/session_model.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';

class ShipmentController extends ChangeNotifier {
  final List<Shipment> _shipments = [];

  bool _isLoading = false;
  String? _error;
  int? _completedSessionShipmentId;
  int? _completedSessionId;

  int? get completedSessionShipmentId => _completedSessionShipmentId;
  int? get completedSessionId => _completedSessionId;
  bool _hasFetched = false;
  String? _clientEmail;

  List<Shipment> get shipments => _shipments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Prevents a silent refresh from racing a foreground fetch (or another
  // silent refresh) and clobbering state out of order.
  bool _isSilentRefreshing = false;

  final Map<int, SessionModel> _sessions = {};

  SessionModel? sessionForShipment(int shipmentId) {
    return _sessions[shipmentId];
  }

  void sessionCompleted({
    required int shipmentId,
    required int sessionId,
  }) {
    _completedSessionShipmentId = shipmentId;
    _completedSessionId = sessionId;

    notifyListeners();
  }

  Future<void> onSessionCreated({
    required int shipmentId,
  }) async {
    final session = await SessionApi.getSessionByShipment(
      shipmentId.toString(),
    );

    if (session == null) return;

    setSession(
      shipmentId,
      session,
    );
  }

  String _normalizeError(Object e) {
    final msg = e.toString().toLowerCase();

    if (msg.contains("no internet") ||
        msg.contains("socketexception") ||
        msg.contains("unreachable") ||
        msg.contains("failed host lookup")) {
      return "No internet connection. Please check your network.";
    }

    if (msg.contains("timeout")) {
      return "Request timed out. Try again.";
    }

    return "Something went wrong. Please try again.";
  }

  void setSession(int shipmentId, SessionModel session) {
    _sessions[shipmentId] = session;
    notifyListeners();
  }

  Future<void> fetchShipmentsByClientEmail({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (_hasFetched && !forceRefresh) return;

    await _fetch();
    _hasFetched = true;
  }

  Future<void> refresh() async {
    await _fetch(forceRefresh: true);
  }

  /// Re-fetches in the background without touching isLoading, so a shipment
  /// list already on screen doesn't flash a spinner. Use this for
  /// socket-triggered refreshes (e.g. a negotiation was accepted and the
  /// order just became a shipment) where a full loading state is just noise.
  ///
  /// Errors are swallowed on purpose — a failed background refresh
  /// shouldn't blank out or error-state a list currently showing valid
  /// (if slightly stale) data. _error/_isLoading are left untouched for
  /// the next real foreground fetch.
  Future<void> refreshSilently() async {
    if (_isSilentRefreshing || _isLoading) return;

    _isSilentRefreshing = true;

    try {
      final data = await ShipmentApi.getShipmentsByClientEmail();

      _shipments
        ..clear()
        ..addAll(data);
      _hasFetched = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("ShipmentController silent refresh error: $e");
      }
      // Intentionally not setting _error here.
    } finally {
      _isSilentRefreshing = false;
    }
  }

  Future<void> _fetch({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ShipmentApi.getShipmentsByClientEmail();

      _shipments
        ..clear()
        ..addAll(data);
    } catch (e) {
      _error = _normalizeError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _shipments.clear();
    _hasFetched = false;
    notifyListeners();
  }
}