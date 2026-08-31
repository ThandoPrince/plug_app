import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import '../retry_policy.dart';

class NegotiationSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  // Read lazily instead of caching at class-load time: if dotenv hasn't
  // finished loading yet (e.g. hot restart, race with main()), a cached
  // static final would freeze an empty base URL for the app's lifetime.
  static String get _baseUrl => dotenv.env['API_BASE_URL_WEBSOKET'] ?? '';

  bool _isManuallyClosed = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isDisconnectHandled = false;

  int? _negotiationId;

  // Bumped on every connect()/disconnect()/teardown. Any in-flight
  // _connectInternal() checks this after each await and bails out if it no
  // longer matches, so a stale attempt can't clobber a newer one.
  int _connectionEpoch = 0;

  Function(Map<String, dynamic>)? _onEvent;
  Function()? _onConnected;
  Function()? _onDisconnected;
  Function(NetworkError)? _onError;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;
  Timer? _connectTimeoutTimer;
  int _retryCount = 0;

  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _heartbeatInterval = Duration(seconds: 25);
  static const Duration _pongTimeout = Duration(seconds: 10);

  static const RetryPolicy _wsRetryPolicy = RetryPolicy(
    maxAttempts: 8,
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
    backoffMultiplier: 2.0,
    jitterFactor: 0.3,
  );

  // Close codes that mean "the server actively rejected this connection"
  // (bad/expired auth, negotiation gone, forbidden). Retrying on these just
  // burns the retry budget on something that will never succeed.
  static const Set<int> _nonRetryableCloseCodes = {4001, 4003, 4004};

  /// -----------------------------
  /// PUBLIC CONNECT
  /// -----------------------------
  void connect({
    required int negotiationId,
    required Function(Map<String, dynamic>) onEvent,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(NetworkError)? onError,
  }) {
    if (_negotiationId == negotiationId && (_isConnected || _isConnecting)) {
      return;
    }

    // Switching targets, or re-connecting after a manual close: tear down
    // whatever's in flight first so old callbacks/timers can't fire late.
    if (_negotiationId != negotiationId || _isManuallyClosed) {
      _teardownActiveConnection(notify: false);
    }

    _negotiationId = negotiationId;
    _onEvent = onEvent;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
    _onError = onError;

    _isManuallyClosed = false;
    _retryCount = 0;

    _connectInternal();
  }

  /// -----------------------------
  /// CORE CONNECTION
  /// -----------------------------
  Future<void> _connectInternal() async {
    if (_isConnecting || _isManuallyClosed) return;
    if (_negotiationId == null) return;

    _isConnecting = true;
    _isDisconnectHandled = false;
    final epoch = ++_connectionEpoch;
    final targetNegotiationId = _negotiationId;

    try {
      final token = await _getValidToken();

      // The world may have changed while we awaited the token (manual
      // disconnect, negotiationId switch, or a newer attempt superseding
      // this one). If so, abandon this attempt quietly.
      if (epoch != _connectionEpoch ||
          _isManuallyClosed ||
          _negotiationId != targetNegotiationId) {
        _isConnecting = false;
        return;
      }

      if (token == null) {
        _isConnecting = false;
        _scheduleReconnect();
        return;
      }

      final base = _baseUrl;
      if (base.isEmpty) {
        if (kDebugMode) {
          print('Negotiation WS: API_BASE_URL_WEBSOKET is not configured.');
        }
        _isConnecting = false;
        _onError?.call(NetworkError(
          type: NetworkErrorType.unknown,
          message: 'WebSocket base URL is not configured.',
        ));
        _scheduleReconnect();
        return;
      }

      final uri = Uri.parse(
        "$base/ws/negotiation/$targetNegotiationId/?token=$token",
      );

      if (kDebugMode) {
        final redacted = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'token': '***redacted***',
        });
        print("Connecting WS: $redacted");
      }

      final channel = WebSocketChannel.connect(uri);

      // Don't assume the handshake succeeded just because connect() didn't
      // throw synchronously. Wait for `ready` (throws on handshake failure)
      // and bound it so a hung handshake can't stall reconnection forever.
      var timedOut = false;
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = Timer(_connectTimeout, () {
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
        throw TimeoutException('WebSocket handshake timed out');
      }

      // Another attempt superseded this one while we awaited `ready`.
      if (epoch != _connectionEpoch ||
          _isManuallyClosed ||
          _negotiationId != targetNegotiationId) {
        unawaited(channel.sink.close());
        _isConnecting = false;
        return;
      }

      _channel = channel;
      _isConnected = true;
      _retryCount = 0;
      _onConnected?.call();

      _startHeartbeat();

      unawaited(_channelSubscription?.cancel());
      _channelSubscription = channel.stream.listen(
        _handleMessage,
        onError: (e) {
          if (kDebugMode) {
            print("WS error: $e");
          }
          _handleError(e, epoch: epoch);
        },
        onDone: () => _handleDisconnect(
          epoch: epoch,
          closeCode: channel.closeCode,
        ),
        cancelOnError: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print("WS connection failed: $e");
      }
      _handleError(e, epoch: epoch);
    } finally {
      _isConnecting = false;
    }
  }

  /// -----------------------------
  /// MESSAGE HANDLER
  /// -----------------------------
  void _handleMessage(dynamic event) {
    if (event == null) return;

    dynamic raw = event;
    if (raw is! String) {
      // Some servers send binary frames instead of text. Try to decode as
      // UTF-8 rather than crashing on the `as String` cast.
      if (raw is List<int>) {
        try {
          raw = utf8.decode(raw);
        } catch (e) {
          if (kDebugMode) print('WS: unreadable binary frame: $e');
          return;
        }
      } else {
        if (kDebugMode) {
          print('WS: ignoring unsupported frame type: ${raw.runtimeType}');
        }
        return;
      }
    }

    try {
      final decoded = jsonDecode(raw as String);

      if (decoded is Map<String, dynamic>) {
        if (decoded['type'] == 'ping') {
          _send({'type': 'pong'});
          return;
        }
        if (decoded['type'] == 'pong') {
          _onPongReceived();
          return;
        }
        _onEvent?.call(decoded);
      } else if (kDebugMode) {
        // Guards the onEvent contract (Map<String, dynamic>) against
        // servers that occasionally send a bare list/string/number.
        print('WS: ignoring non-object payload: $decoded');
      }
    } catch (e) {
      if (kDebugMode) {
        print("WS decode error: $e");
      }
    }
  }

  /// -----------------------------
  /// HEARTBEAT
  /// -----------------------------
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _sendPing());
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
      _handleDisconnect();
      return;
    }

    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(_pongTimeout, () {
      if (kDebugMode) {
        print('Negotiation WS heartbeat timeout: no pong received.');
      }
      _handleDisconnect();
    });
  }

  void _onPongReceived() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  bool _send(Map<String, dynamic> payload) {
    if (_channel == null || !_isConnected) return false;
    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (e) {
      if (kDebugMode) print('Negotiation WS send failed: $e');
      return false;
    }
  }

  /// -----------------------------
  /// ERROR / DISCONNECT HANDLING
  /// -----------------------------
  void _handleError(dynamic error, {int? epoch}) {
    // Ignore errors from an attempt that's already been superseded/torn down.
    if (epoch != null && epoch != _connectionEpoch) return;

    _stopHeartbeat();

    NetworkError networkError;
    if (error is SocketException) {
      networkError = NetworkError.fromException(error);
    } else if (error is TimeoutException) {
      networkError = NetworkError.fromException(error);
    } else {
      networkError = NetworkError(
        type: NetworkErrorType.unknown,
        message: error.toString(),
        originalError: error,
      );
    }

    _onError?.call(networkError);
    _handleDisconnect(epoch: epoch);
  }

  void _handleDisconnect({int? epoch, int? closeCode}) {
    if (_isManuallyClosed) return;
    if (epoch != null && epoch != _connectionEpoch) return;
    // Both the stream's onError and onDone can fire for the same drop;
    // make sure we only process it once.
    if (_isDisconnectHandled) return;
    _isDisconnectHandled = true;

    _isConnected = false;
    _stopHeartbeat();

    unawaited(_channelSubscription?.cancel());
    _channelSubscription = null;
    _channel = null;

    _onDisconnected?.call();

    if (closeCode != null && _nonRetryableCloseCodes.contains(closeCode)) {
      if (kDebugMode) {
        print('Negotiation WS: non-retryable close code $closeCode, giving up.');
      }
      _onError?.call(NetworkError(
        type: NetworkErrorType.serverError,
        message:
            'Connection was rejected by the server. Please rejoin the negotiation.',
      ));
      return;
    }

    _scheduleReconnect();
  }

  /// -----------------------------
  /// TOKEN REFRESH
  /// -----------------------------
  Future<String?> _getValidToken() async {
    try {
      return await AuthSessionController.instance.getValidAccessToken();
    } catch (e) {
      if (kDebugMode) print('Negotiation WS: failed to fetch token: $e');
      return null;
    }
  }

  /// -----------------------------
  /// RECONNECT BACKOFF
  /// -----------------------------
  void _scheduleReconnect() {
    if (_isManuallyClosed) return;
    if (_retryCount >= _wsRetryPolicy.maxAttempts) {
      if (kDebugMode) {
        print('Negotiation WS: max reconnect attempts reached, giving up.');
      }
      _onError?.call(NetworkError(
        type: NetworkErrorType.serverError,
        message: 'Connection lost. Please restart the negotiation.',
      ));
      return;
    }

    _retryCount++;

    final delay = _wsRetryPolicy.delayForAttempt(_retryCount - 1);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connectInternal);
  }

  /// Call this when connectivity is regained (e.g. from a connectivity_plus
  /// listener) to retry immediately instead of waiting out the current
  /// backoff delay, or to recover after max attempts were exhausted.
  void resetAndReconnect() {
    if (_isManuallyClosed || _negotiationId == null) return;
    _retryCount = 0;
    _reconnectTimer?.cancel();
    if (!_isConnected && !_isConnecting) {
      _connectInternal();
    }
  }

  void _teardownActiveConnection({required bool notify}) {
    _connectionEpoch++; // invalidates any in-flight _connectInternal
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    _stopHeartbeat();
    unawaited(_channelSubscription?.cancel());
    _channelSubscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;

    final wasConnected = _isConnected;
    _isConnected = false;
    _isConnecting = false;
    if (notify && wasConnected) {
      _onDisconnected?.call();
    }
  }

  /// -----------------------------
  /// DISCONNECT
  /// -----------------------------
  void disconnect() {
    _isManuallyClosed = true;
    _teardownActiveConnection(notify: false);

    _negotiationId = null;
    _retryCount = 0;

    // Drop callbacks so a stray late timer/stream event can't invoke a
    // listener that belongs to an already-disposed widget/controller.
    _onEvent = null;
    _onConnected = null;
    _onDisconnected = null;
    _onError = null;
  }

  bool get isConnected => _isConnected;
}