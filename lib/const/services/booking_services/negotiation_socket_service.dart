import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

class NegotiationSocketService {
  WebSocketChannel? _channel;

  static final String baseUrl =
      dotenv.env['API_BASE_URL_WEBSOKET'] ?? '';

  bool _isManuallyClosed = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  int? _negotiationId;

  Function(Map<String, dynamic>)? _onEvent;
  Function()? _onConnected;
  Function()? _onDisconnected;

  Timer? _reconnectTimer;
  int _retryCount = 0;

  static const Duration _connectTimeout = Duration(seconds: 10);

  /// -----------------------------
  /// PUBLIC CONNECT
  /// -----------------------------
  void connect({
    required int negotiationId,
    required Function(Map<String, dynamic>) onEvent,
    Function()? onConnected,
    Function()? onDisconnected,
  }) {
    if (_negotiationId == negotiationId && _isConnected) return;

    _negotiationId = negotiationId;
    _onEvent = onEvent;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;

    _isManuallyClosed = false;
    _retryCount = 0;

    _connectInternal();
  }

  /// -----------------------------
  /// CORE CONNECTION
  /// -----------------------------
  Future<void> _connectInternal() async {
    if (_isConnecting || _isManuallyClosed) return;

    _isConnecting = true;

    try {
      final token = await _getValidToken();
      if (token == null || _negotiationId == null) return;

      final uri = Uri.parse(
        "$baseUrl/ws/negotiation/$_negotiationId/?token=$token",
      );

      if (kDebugMode) {
        print("Connecting WS: $uri");
      }

      final channel = WebSocketChannel.connect(uri);

      _channel = channel;

      // Mark connected only after stream starts
      _isConnected = true;
      _onConnected?.call();

      channel.stream.listen(
        _handleMessage,
        onError: (e) {
          if (kDebugMode) {
            print("WS error: $e");
          }
          _handleDisconnect();
        },
        onDone: () => _handleDisconnect(),
        cancelOnError: true,
      );

      _retryCount = 0;
    } catch (e) {
      if (kDebugMode) {
        print("WS connection failed: $e");
      }
      _handleDisconnect();
    } finally {
      _isConnecting = false;
    }
  }

  /// -----------------------------
  /// MESSAGE HANDLER
  /// -----------------------------
  void _handleMessage(dynamic event) {
    if (event == null) return;

    try {
      final data = jsonDecode(event as String);
      _onEvent?.call(data);
    } catch (e) {
      if (kDebugMode) {
        print("WS decode error: $e");
      }
    }
  }

  /// -----------------------------
  /// DISCONNECT HANDLER
  /// -----------------------------
  void _handleDisconnect() {
    if (_isManuallyClosed) return;

    _isConnected = false;
    _channel = null;

    _onDisconnected?.call();
    _scheduleReconnect();
  }

  /// -----------------------------
  /// TOKEN REFRESH
  /// -----------------------------
  Future<String?> _getValidToken() async {
    return await AuthSessionController.instance.getValidAccessToken();
  }

  /// -----------------------------
  /// RECONNECT BACKOFF
  /// -----------------------------
  void _scheduleReconnect() {
    if (_isManuallyClosed) return;
    if (_retryCount >= 5) return;

    _retryCount++;

    final delay = Duration(
      seconds: (2 << (_retryCount - 1)).clamp(2, 30),
    );

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(delay, _connectInternal);
  }

  /// -----------------------------
  /// DISCONNECT
  /// -----------------------------
  void disconnect() {
    _isManuallyClosed = true;

    _reconnectTimer?.cancel();

    _channel?.sink.close();
    _channel = null;

    _isConnected = false;
    _negotiationId = null;
    _retryCount = 0;
  }

  bool get isConnected => _isConnected;
}