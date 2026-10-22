import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import '../retry_policy.dart';

class ClientOrderSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  static String get _baseUrl => dotenv.env['API_BASE_URL_WEBSOKET'] ?? '';

  bool _isManuallyClosed = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isDisconnectHandled = false;

  int? _userId;

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

  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _heartbeatInterval = Duration(seconds: 25);
  static const Duration _pongTimeout = Duration(seconds: 15);

  static const RetryPolicy _wsRetryPolicy = RetryPolicy(
    maxAttempts: 8,
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
    backoffMultiplier: 2.0,
    jitterFactor: 0.3,
  );

  static const Set<int> _nonRetryableCloseCodes = {4001, 4003, 4004};

  void connect({
    required int userId,
    required Function(Map<String, dynamic>) onEvent,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(NetworkError)? onError,
  }) {
    if (_userId == userId && (_isConnected || _isConnecting)) {
      return;
    }

    if (_userId != userId || _isManuallyClosed) {
      _teardownActiveConnection(notify: false);
    }

    _userId = userId;
    _onEvent = onEvent;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
    _onError = onError;

    _isManuallyClosed = false;
    _retryCount = 0;

    _connectInternal();
  }

  Future<void> _connectInternal() async {
    if (_isConnecting || _isManuallyClosed) return;
    if (_userId == null) return;

    _isConnecting = true;
    _isDisconnectHandled = false;
    final epoch = ++_connectionEpoch;
    final targetUserId = _userId;

    try {
      final token = await _getValidToken();

      if (epoch != _connectionEpoch ||
          _isManuallyClosed ||
          _userId != targetUserId) {
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
          print('Client WS: API_BASE_URL_WEBSOKET is not configured.');
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
        "$base/ws/client/$targetUserId/?token=$token",
      );

      if (kDebugMode) {
        final redacted = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'token': '***redacted***',
        });
        print("Connecting Client WS: $redacted");
      }

      final channel = WebSocketChannel.connect(uri);

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

      if (epoch != _connectionEpoch ||
          _isManuallyClosed ||
          _userId != targetUserId) {
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
            print("Client WS error: $e");
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
        print("Client WS connection failed: $e");
      }
      _handleError(e, epoch: epoch);
    } finally {
      _isConnecting = false;
    }
  }

  void _handleMessage(dynamic event) {
    if (event == null) return;

    dynamic raw = event;
    if (raw is! String) {
      if (raw is List<int>) {
        try {
          raw = utf8.decode(raw);
        } catch (e) {
          if (kDebugMode) print('Client WS: unreadable binary frame: $e');
          return;
        }
      } else {
        if (kDebugMode) {
          print('Client WS: ignoring unsupported frame type: ${raw.runtimeType}');
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
        // "connected" is a handshake ack from ClientBaseAppConsumer, not a
        // domain event — swallow it here so callers never need to filter it.
        if (decoded['type'] == 'connected') {
          return;
        }
        _onEvent?.call(decoded);
      } else if (kDebugMode) {
        print('Client WS: ignoring non-object payload: $decoded');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Client WS decode error: $e");
      }
    }
  }

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
        print('Client WS heartbeat timeout: no pong received.');
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
      if (kDebugMode) print('Client WS send failed: $e');
      return false;
    }
  }

  void _handleError(dynamic error, {int? epoch}) {
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
        print('Client WS: non-retryable close code $closeCode, giving up.');
      }
      _onError?.call(NetworkError(
        type: NetworkErrorType.serverError,
        message: 'Connection was rejected by the server.',
      ));
      return;
    }

    _scheduleReconnect();
  }

  Future<String?> _getValidToken() async {
    try {
      return await AuthSessionController.instance.getValidAccessToken();
    } catch (e) {
      if (kDebugMode) print('Client WS: failed to fetch token: $e');
      return null;
    }
  }

  void _scheduleReconnect() {
    if (_isManuallyClosed) return;
    if (_retryCount >= _wsRetryPolicy.maxAttempts) {
      if (kDebugMode) {
        print('Client WS: max reconnect attempts reached, giving up.');
      }
      _onError?.call(NetworkError(
        type: NetworkErrorType.serverError,
        message: 'Connection lost.',
      ));
      return;
    }

    _retryCount++;

    final delay = _wsRetryPolicy.delayForAttempt(_retryCount - 1);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connectInternal);
  }

  void resetAndReconnect() {
    if (_isManuallyClosed || _userId == null) return;
    _retryCount = 0;
    _reconnectTimer?.cancel();
    if (!_isConnected && !_isConnecting) {
      _connectInternal();
    }
  }

  void _teardownActiveConnection({required bool notify}) {
    _connectionEpoch++;
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

  void disconnect() {
    _isManuallyClosed = true;
    _teardownActiveConnection(notify: false);

    _userId = null;
    _retryCount = 0;

    _onEvent = null;
    _onConnected = null;
    _onDisconnected = null;
    _onError = null;
  }

  bool get isConnected => _isConnected;
}