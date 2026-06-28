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
  final session =
      await SessionApi.getSessionByShipment(
        shipmentId.toString(),
      );

  if (session == null) return;

  setSession(
    shipmentId,
    session,
  );
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
      _error = e.toString();
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