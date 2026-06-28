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

  void disconnect() {
    _socket.disconnect();
    _connected = false;
    _activeId = null;
    notifyListeners();
  }
}