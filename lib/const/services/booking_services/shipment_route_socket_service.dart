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
///  - A real handshake wait (`channel.ready`) so `isConnected` only reports
///    true once the socket is actually open, with a connect timeout that
///    genuinely aborts a hung handshake.
///  - An epoch counter so a stale in-flight connect attempt (superseded by
///    a shipment switch, disconnect(), or dispose()) can never clobber a
///    newer one or open a socket after manual close.
///  - A `dispose()` that fully tears the service down (use in State.dispose()).
class ShipmentRouteSocketService {
  ShipmentRouteSocketService({
    this.heartbeatInterval = const Duration(seconds: 20),
    this.pongTimeout = const Duration(seconds: 8),
    this.connectTimeout = const Duration(seconds: 10),
    this.maxRetries = 8,
    this.maxReconnectDelay = const Duration(seconds: 30),
  }) : assert(maxReconnectDelay >= const Duration(seconds: 1),
            'maxReconnectDelay must be at least 1 second');

  // Read lazily rather than caching at class-load time: if dotenv hasn't
  // finished loading yet (hot restart, race with main()), a cached
  // static final would freeze an empty base URL for the app's lifetime.
  static String get _baseUrl => dotenv.env['API_BASE_URL_WEBSOKET'] ?? '';

  /// How often to send an application-level ping once connected.
  final Duration heartbeatInterval;

  /// How long to wait for a pong before treating the connection as dead.
  final Duration pongTimeout;

  /// How long to wait for the initial handshake before giving up on it.
  final Duration connectTimeout;

  /// Max number of consecutive reconnect attempts before giving up.
  final int maxRetries;

  /// Ceiling for the exponential backoff delay.
  final Duration maxReconnectDelay;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;

  bool _isConnecting = false;
  bool _isManuallyClosed = false;
  bool _isDisposed = false;
  bool _isDisconnectHandled = false;

  int? _shipmentId;

  // Bumped on every connect()/disconnect()/dispose()/teardown. An in-flight
  // _connectInternal() checks this after each await and bails out if it no
  // longer matches, so a stale attempt can't open a socket after the world
  // has moved on (shipment switched, manually disconnected, disposed).
  int _connectionEpoch = 0;

  Function(Map<String, dynamic>)? _onEvent;
  Function()? _onConnected;
  Function()? _onDisconnected;
  Function(Object error)? _onError;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;
  Timer? _connectTimeoutTimer;

  int _retryCount = 0;
  final Random _rng = Random();

  // Close codes meaning "the server actively rejected this" (bad/expired
  // auth, shipment gone, forbidden). Retrying on these just burns the
  // retry budget on something that will never succeed.
  static const Set<int> _nonRetryableCloseCodes = {4001, 4003, 4004};

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

    // Already connected (or actively connecting) to this shipment: no-op,
    // but refresh callbacks in case a new caller re-registered them.
    if (_shipmentId == shipmentId && (_channel != null || _isConnecting)) {
      _onEvent = onEvent;
      _onConnected = onConnected;
      _onDisconnected = onDisconnected;
      _onError = onError;
      return;
    }

    // Switching shipments, or reconnecting after a manual close: tear down
    // anything in flight first (including a pending reconnect timer) so a
    // stale attempt can't leak a duplicate socket later.
    _teardownChannel();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

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
    if (_channel != null) return; // already have a live socket

    _isConnecting = true;
    _isDisconnectHandled = false;
    final epoch = ++_connectionEpoch;
    final targetShipmentId = _shipmentId;

    try {
      final token = await AuthSessionController.instance.getValidAccessToken();

      // The world may have changed while we awaited the token (manual
      // disconnect, dispose, or a shipment switch superseding this
      // attempt). Bail out quietly rather than opening a socket nobody
      // wants anymore.
      if (epoch != _connectionEpoch ||
          _isManuallyClosed ||
          _isDisposed ||
          _shipmentId != targetShipmentId) {
        _isConnecting = false;
        return;
      }

      if (token == null || targetShipmentId == null) {
        _isConnecting = false;
        _scheduleReconnect();
        return;
      }

      final base = _baseUrl;
      if (base.isEmpty) {
        if (kDebugMode) {
          print('Shipment socket: API_BASE_URL_WEBSOKET is not configured.');
        }
        _isConnecting = false;
        _onError?.call(StateError('WebSocket base URL is not configured.'));
        _scheduleReconnect();
        return;
      }

      final uri = Uri.parse(
        '$base/ws/shipments/$targetShipmentId/route/?token=$token',
      );

      if (kDebugMode) {
        final redacted = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'token': '***redacted***',
        });
        print('Connecting shipment socket: $redacted');
      }

      final channel = WebSocketChannel.connect(uri);

      // `WebSocketChannel.connect()` returns immediately; it does not wait
      // for the handshake. Waiting on `.ready` (and bounding it with a real
      // timer) is what actually confirms the socket opened, instead of
      // treating "constructor didn't throw" as "connected".
      var timedOut = false;
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = Timer(connectTimeout, () {
        timedOut = true;
        channel.sink.close();
      });

      try {
        await channel.ready;
      } finally {
        _connectTimeoutTimer?.cancel();
        _connectTimeoutTimer = null;
      }

      if (timedOut) {
        throw TimeoutException('Shipment socket handshake timed out');
      }

      // Superseded again while we awaited the handshake.
      if (epoch != _connectionEpoch ||
          _isManuallyClosed ||
          _isDisposed ||
          _shipmentId != targetShipmentId) {
        unawaited(channel.sink.close());
        _isConnecting = false;
        return;
      }

      _channel = channel;
      _retryCount = 0;

      _onConnected?.call();

      _channelSub = channel.stream.listen(
        _handleMessage,
        onDone: () {
          if (kDebugMode) print('Shipment socket closed.');
          _teardownChannel(notify: true, closeCode: channel.closeCode);
        },
        onError: (error) {
          if (kDebugMode) print('Shipment socket error: $error');
          _onError?.call(error);
          _teardownChannel(notify: true, closeCode: channel.closeCode);
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

    dynamic raw = event;
    if (raw is! String) {
      // Some servers send binary frames instead of text; try UTF-8 rather
      // than crashing on the `as String` cast below.
      if (raw is List<int>) {
        try {
          raw = utf8.decode(raw);
        } catch (e) {
          if (kDebugMode) print('Shipment socket: unreadable binary frame: $e');
          return;
        }
      } else {
        if (kDebugMode) {
          print('Shipment socket: ignoring unsupported frame type: ${raw.runtimeType}');
        }
        return;
      }
    }

    try {
      if (kDebugMode) print('RAW WS MESSAGE: $raw');

      final data = jsonDecode(raw as String);

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
  /// Idempotent: safe to call even if there's nothing to tear down, and
  /// guards against onError + onDone both firing for the same drop.
  void _teardownChannel({bool notify = false, int? closeCode}) {
    if (notify) {
      if (_isDisconnectHandled) return;
      _isDisconnectHandled = true;
    }

    _connectionEpoch++; // invalidate any in-flight _connectInternal
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    _stopHeartbeat();

    unawaited(_channelSub?.cancel());
    _channelSub = null;

    unawaited(_channel?.sink.close());
    _channel = null;

    if (notify) {
      if (closeCode != null && _nonRetryableCloseCodes.contains(closeCode)) {
        if (kDebugMode) {
          print('Shipment socket: non-retryable close code $closeCode, giving up.');
        }
        _onDisconnected?.call();
        _onError?.call(StateError(
            'Connection was rejected by the server (code $closeCode).'));
        return;
      }
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

    final maxDelayMs = maxReconnectDelay.inMilliseconds;
    final baseDelayMs = min(
      1000 * pow(2, _retryCount - 1).toInt(),
      maxDelayMs,
    );
    // +/- up to 30% jitter to avoid thundering-herd reconnects.
    final jitterMs = (baseDelayMs * 0.3 * (_rng.nextDouble() * 2 - 1)).toInt();
    final lowerBoundMs = min(1000, maxDelayMs);
    final delay = Duration(
      milliseconds: (baseDelayMs + jitterMs).clamp(lowerBoundMs, maxDelayMs),
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connectInternal);
  }

  /// Call this when connectivity is regained (e.g. from a connectivity_plus
  /// listener) to retry immediately instead of waiting out the current
  /// backoff delay, or to recover after max attempts were exhausted.
  void resetAndReconnect() {
    if (_isManuallyClosed || _isDisposed || _shipmentId == null) return;
    _retryCount = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (_channel == null && !_isConnecting) {
      _connectInternal();
    }
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

  /// True only once the handshake has actually completed, not just when a
  /// channel object exists.
  bool get isConnected => _channel != null && !_isConnecting;
}