import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class ShipmentRouteSocketService {
  WebSocketChannel? _channel;

  static final String baseUrl =
      dotenv.env['API_BASE_URL_WEBSOKET'] ?? '';

  bool _isConnecting = false;
  bool _isManuallyClosed = false;

  int? _shipmentId;

  Function(Map<String, dynamic>)? _onEvent;
  Function()? _onConnected;
  Function()? _onDisconnected;

  Timer? _reconnectTimer;
  int _retryCount = 0;

  //--------------------------------------------------------
  // CONNECT
  //--------------------------------------------------------

  

  void connect({
    required int shipmentId,
    required Function(Map<String, dynamic>) onEvent,
    Function()? onConnected,
    Function()? onDisconnected,
  }) {
    if (_shipmentId == shipmentId && _channel != null) {
      return;
    }

    _shipmentId = shipmentId;

    _onEvent = onEvent;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;

    _retryCount = 0;
    _isManuallyClosed = false;

    _connectInternal();
  }

  //--------------------------------------------------------
  // INTERNAL CONNECT
  //--------------------------------------------------------

  Future<void> _connectInternal() async {
  if (_isConnecting || _isManuallyClosed) return;

  _isConnecting = true;

  try {
    final token =
        await AuthSessionController.instance.getValidAccessToken();

    if (token == null || _shipmentId == null) {
      return;
    }

    final uri = Uri.parse(
      "$baseUrl/ws/shipments/$_shipmentId/route/?token=$token",
    );

    if (kDebugMode) {
      print("Connecting shipment socket...");
      print(uri);
    }

    final channel = await Future<WebSocketChannel>(() {
      return WebSocketChannel.connect(uri);
    }).timeout(const Duration(seconds: 10));

    _channel = channel;

    _onConnected?.call();

    _channel!.stream.listen(
      _handleMessage,
      onDone: () {
        if (kDebugMode) {
          print("Shipment socket closed.");
        }

        _channel = null;
        _scheduleReconnect();
      },
      onError: (error) {
        if (kDebugMode) {
          print("Shipment socket error: $error");
        }

        _channel = null;
        _scheduleReconnect();
      },
      cancelOnError: true,
    );

    _retryCount = 0;
  } on TimeoutException {
    if (kDebugMode) {
      print("Shipment socket connection timed out.");
    }

    _channel = null;
    _scheduleReconnect();
  } catch (e) {
    if (kDebugMode) {
      print("Shipment socket connection failed: $e");
    }

    _channel = null;
    _scheduleReconnect();
  } finally {
    _isConnecting = false;
  }
}

  //--------------------------------------------------------
  // MESSAGE
  //--------------------------------------------------------

void _handleMessage(dynamic event) {
  if (event == null) return;

  try {
    if (kDebugMode) {
      print("RAW WS MESSAGE: $event");
    }

    final data = jsonDecode(event as String);

    if (kDebugMode) {
      print("DECODED WS MESSAGE: $data");
    }

    _onEvent?.call(data);
  } catch (e) {
    if (kDebugMode) {
      print("WS decode error: $e");
    }
  }
}

  //--------------------------------------------------------
  // RECONNECT
  //--------------------------------------------------------

  void _scheduleReconnect() {
    if (_isManuallyClosed) return;

    _onDisconnected?.call();

    if (_retryCount >= 5) {
      return;
    }

    _retryCount++;

    final delay = Duration(
      seconds: (2 << (_retryCount - 1)).clamp(2, 30),
    );

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(delay, () {
      _connectInternal();
    });
  }

  //--------------------------------------------------------
  // DISCONNECT
  //--------------------------------------------------------

  void disconnect() {
  _isManuallyClosed = true;

  _reconnectTimer?.cancel();
  _reconnectTimer = null;

  _channel?.sink.close();
  _channel = null;

  _shipmentId = null;

  _retryCount = 0;
  _isConnecting = false;
}

  bool get isConnected => _channel != null;
}