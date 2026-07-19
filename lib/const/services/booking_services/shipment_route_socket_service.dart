import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

/// Production WebSocket client for shipment route updates.
///
/// Adds on top of a plain connect/listen loop:
///  - Application-level heartbeat (ping/pong) so dead connections
///    (e.g. behind NAT/proxies that silently drop idle sockets) are
///    detected instead of hanging forever.
///  - A pong watchdog: if the server doesn't answer a ping in time,
///    the socket is force-closed and a reconnect is scheduled.
///  - Exponential backoff with jitter for reconnects, capped at a max delay.
///  - Proper subscription lifecycle (no leaked listeners across reconnects).
///  - A `dispose()` that fully tears the service down (use in State.dispose()).
class ShipmentRouteSocketService {
  ShipmentRouteSocketService({
    this.heartbeatInterval = const Duration(seconds: 20),
    this.pongTimeout = const Duration(seconds: 8),
    this.maxRetries = 8,
    this.maxReconnectDelay = const Duration(seconds: 30),
  });

  static final String baseUrl = dotenv.env['API_BASE_URL_WEBSOKET'] ?? '';

  /// How often to send an application-level ping once connected.
  final Duration heartbeatInterval;

  /// How long to wait for a pong before treating the connection as dead.
  final Duration pongTimeout;

  /// Max number of consecutive reconnect attempts before giving up.
  final int maxRetries;

  /// Ceiling for the exponential backoff delay.
  final Duration maxReconnectDelay;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;

  bool _isConnecting = false;
  bool _isManuallyClosed = false;
  bool _isDisposed = false;

  int? _shipmentId;

  Function(Map<String, dynamic>)? _onEvent;
  Function()? _onConnected;
  Function()? _onDisconnected;
  Function(Object error)? _onError;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;

  int _retryCount = 0;
  final Random _rng = Random();

  //--------------------------------------------------------
  // CONNECT
  //--------------------------------------------------------

  void connect({
    required int shipmentId,
    required Function(Map<String, dynamic>) onEvent,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(Object error)? onError,
  }) {
    if (_isDisposed) {
      if (kDebugMode) {
        print('ShipmentRouteSocketService: connect() called after dispose().');
      }
      return;
    }

    // Already connected to this shipment: no-op.
    if (_shipmentId == shipmentId && _channel != null) {
      return;
    }

    // Switching shipments while connected: tear down the old socket first.
    if (_shipmentId != shipmentId && _channel != null) {
      _teardownChannel();
    }

    _shipmentId = shipmentId;
    _onEvent = onEvent;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
    _onError = onError;

    _retryCount = 0;
    _isManuallyClosed = false;

    _connectInternal();
  }

  //--------------------------------------------------------
  // INTERNAL CONNECT
  //--------------------------------------------------------

  Future<void> _connectInternal() async {
    if (_isConnecting || _isManuallyClosed || _isDisposed) return;

    _isConnecting = true;

    try {
      final token = await AuthSessionController.instance.getValidAccessToken();

      if (token == null || _shipmentId == null) {
        _isConnecting = false;
        _scheduleReconnect();
        return;
      }

      final uri = Uri.parse(
        '$baseUrl/ws/shipments/$_shipmentId/route/?token=$token',
      );

      if (kDebugMode) {
        print('Connecting shipment socket...');
        print(uri);
      }

      final channel = await Future<WebSocketChannel>(() {
        return WebSocketChannel.connect(uri);
      }).timeout(const Duration(seconds: 10));

      // If a disconnect/dispose happened while we were awaiting, bail out.
      if (_isManuallyClosed || _isDisposed) {
        unawaited(channel.sink.close());
        return;
      }

      _channel = channel;
      _retryCount = 0;

      _onConnected?.call();

      _channelSub = _channel!.stream.listen(
        _handleMessage,
        onDone: () {
          if (kDebugMode) print('Shipment socket closed.');
          _teardownChannel(notify: true);
        },
        onError: (error) {
          if (kDebugMode) print('Shipment socket error: $error');
          _onError?.call(error);
          _teardownChannel(notify: true);
        },
        cancelOnError: true,
      );

      _startHeartbeat();
    } on TimeoutException {
      if (kDebugMode) print('Shipment socket connection timed out.');
      _channel = null;
      _scheduleReconnect();
    } catch (e) {
      if (kDebugMode) print('Shipment socket connection failed: $e');
      _onError?.call(e);
      _channel = null;
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  //--------------------------------------------------------
  // MESSAGE HANDLING
  //--------------------------------------------------------

  void _handleMessage(dynamic event) {
    if (event == null) return;

    try {
      if (kDebugMode) print('RAW WS MESSAGE: $event');

      final data = jsonDecode(event as String);

      if (kDebugMode) print('DECODED WS MESSAGE: $data');

      if (data is Map<String, dynamic>) {
        // Heartbeat reply: swallow it, don't forward to consumers.
        if (data['type'] == 'pong') {
          _onPongReceived();
          return;
        }

        // Server-initiated ping: reply so the server's own watchdog
        // (if any) sees this client as alive.
        if (data['type'] == 'ping') {
          _send({'type': 'pong'});
          return;
        }

        _onEvent?.call(data);
      }
    } catch (e) {
      if (kDebugMode) print('WS decode error: $e');
    }
  }

  //--------------------------------------------------------
  // HEARTBEAT
  //--------------------------------------------------------

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => _sendPing());
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  void _sendPing() {
    if (_channel == null) return;

    if (!_send({'type': 'ping'})) {
      // Send failed outright: treat the connection as dead now.
      _teardownChannel(notify: true);
      return;
    }

    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(pongTimeout, () {
      if (kDebugMode) {
        print('Shipment socket heartbeat timeout: no pong received.');
      }
      _teardownChannel(notify: true);
    });
  }

  void _onPongReceived() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  bool _send(Map<String, dynamic> payload) {
    if (_channel == null) return false;
    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (e) {
      if (kDebugMode) print('Shipment socket send failed: $e');
      return false;
    }
  }

  //--------------------------------------------------------
  // TEARDOWN / RECONNECT
  //--------------------------------------------------------

  /// Closes and clears the current channel/subscription/heartbeat state,
  /// then optionally notifies the listener and schedules a reconnect.
  void _teardownChannel({bool notify = false}) {
    _stopHeartbeat();

    _channelSub?.cancel();
    _channelSub = null;

    _channel?.sink.close();
    _channel = null;

    if (notify) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isManuallyClosed || _isDisposed) return;

    _onDisconnected?.call();

    if (_retryCount >= maxRetries) {
      if (kDebugMode) {
        print('Shipment socket: max reconnect attempts reached, giving up.');
      }
      return;
    }

    _retryCount++;

    final baseDelayMs = min(
      1000 * pow(2, _retryCount - 1).toInt(),
      maxReconnectDelay.inMilliseconds,
    );
    // +/- up to 30% jitter to avoid thundering-herd reconnects.
    final jitterMs = (baseDelayMs * 0.3 * (_rng.nextDouble() * 2 - 1)).toInt();
    final delay = Duration(
      milliseconds: (baseDelayMs + jitterMs).clamp(1000, maxReconnectDelay.inMilliseconds),
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connectInternal);
  }

  //--------------------------------------------------------
  // DISCONNECT / DISPOSE
  //--------------------------------------------------------

  /// Closes the connection and stops all retry/heartbeat activity.
  /// The service can be reused afterwards via connect().
  void disconnect() {
    _isManuallyClosed = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _teardownChannel();

    _shipmentId = null;
    _retryCount = 0;
    _isConnecting = false;
  }

  /// Permanently shuts the service down. Call this from State.dispose().
  /// After calling this, connect() is a no-op.
  void dispose() {
    _isDisposed = true;
    disconnect();
    _onEvent = null;
    _onConnected = null;
    _onDisconnected = null;
    _onError = null;
  }

  bool get isConnected => _channel != null;
}