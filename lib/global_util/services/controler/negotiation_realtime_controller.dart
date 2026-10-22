import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/negotiation_socket_service.dart';

class NegotiationRealtimeController extends ChangeNotifier {
  final NegotiationSocketService _socket = NegotiationSocketService();

  bool _connected = false;
  bool get connected => _connected;

  int? _activeId;

  void connect(
    int negotiationId,
    Function(Map<String, dynamic>) onEvent,
  ) {
    if (_activeId == negotiationId && _connected) return;

    _activeId = negotiationId;

    _socket.connect(
      negotiationId: negotiationId,
      onEvent: (data) {
        // NO notifyListeners here (prevents UI spam)
        onEvent(data);
      },
      onConnected: () {
        _connected = true;
        notifyListeners(); // only state change
      },
      onDisconnected: () {
        _connected = false;
        notifyListeners(); // only state change
      },
    );
  }

  /// Tears down the socket without calling notifyListeners(). Use this
  /// when disconnecting from a widget's dispose() — the tree is locked
  /// during unmount, and notifyListeners() there throws
  /// "setState() or markNeedsBuild() called when widget tree was locked."
  void disconnectSilently() {
    _socket.disconnect();
    _connected = false;
    _activeId = null;
  }

  void disconnect() {
    _socket.disconnect();
    _connected = false;
    _activeId = null;
    notifyListeners();
  }
}