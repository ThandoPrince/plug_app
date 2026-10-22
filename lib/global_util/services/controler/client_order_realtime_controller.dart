import 'package:flutter/foundation.dart';

import 'package:flutter_application_1/const/services/client_services/client_order_socket_service.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_controller_cache.dart';

class ClientOrderRealtimeController extends ChangeNotifier {
  final ClientOrderSocketService _socket = ClientOrderSocketService();

  bool _connected = false;
  bool get connected => _connected;

  int? _activeUserId;

  Function(Map<String, dynamic>)? onBookingUpdate;
  Function(Map<String, dynamic>)? onLocationUpdate;
  Function(Map<String, dynamic>)? onShipmentRouteUpdated;
  Function(Map<String, dynamic>)? onShipmentStatusUpdated;

  /// Fired after the cache is updated, only for a round created while the
  /// negotiation sheet was closed. Payload: {negotiationId, orderId}.
  Function(int negotiationId, int? orderId, NegotiationRound round)? onNegotiationRoundReceived;

  /// Fired after the cache refetch, for a status change (e.g. accepted).
  /// Payload: {negotiationId, orderId}.
  Function(int negotiationId, int? orderId)? onNegotiationStatusChanged;

  void connect(int userId) {
    if (_activeUserId == userId && _connected) return;

    _activeUserId = userId;

    _socket.connect(
      userId: userId,
      onEvent: _dispatch,
      onConnected: () {
        _connected = true;
        notifyListeners();
      },
      onDisconnected: () {
        _connected = false;
        notifyListeners();
      },
    );
  }

  void _dispatch(Map<String, dynamic> event) {
    if (kDebugMode) {
      print('ClientOrderRealtimeController received event: $event');
    }

  final unwrapped = _unwrapNotification(event);
  final type = unwrapped['type'];
  final data = unwrapped['data'];

    switch (type) {
      case 'negotiation_round_created':
      case 'negotiation_counter_offer':
        _handleIncomingRound(data);
        break;

      case 'negotiation_status_changed':
        _handleStatusChanged(data);
        break;

      case 'booking_update':
        onBookingUpdate?.call(data);
        break;

      case 'location_update':
        onLocationUpdate?.call(data);
        break;

      case 'shipment_route_updated':
        onShipmentRouteUpdated?.call(data);
        break;

      case 'shipment_status_updated':
        onShipmentStatusUpdated?.call(data);
        break;

      default:
        if (kDebugMode) {
          print('ClientOrderRealtimeController: unhandled event type $type');
        }
    }
  }

Map<String, dynamic> _unwrapNotification(Map<String, dynamic> event) {
  final data = event['data'];
  if (event['type'] != 'booking_update' ||
      data is! Map ||
      data['event'] != 'notification') {
    return event;
  }

  final n = data['notification'];
  if (n is! Map) return event;
  final payload = n['payload'];
  if (payload is! Map) return event;

  final nType = n['type']?.toString();

  switch (nType) {
    case 'negotiation_round_created':
    case 'negotiation_counter_offer':
      final round = payload['round'];
      if (round is! Map) return event;
      return {
        'type': nType,
        'data': {
          'negotiation_id': payload['negotiation']?['id'],
          'round': {
            ...Map<String, dynamic>.from(round),
            'negotiation': payload['negotiation']?['id'],
            'order_id': payload['order']?['id'],
            // server omitted it; used for bubble timestamp
            'created_at': round['created_at'] ??
                DateTime.now().toUtc().toIso8601String(),
          },
        },
      };

    default:
      return event; // other notification types still go to onBookingUpdate
  }
}

final Set<int> _seenRoundIds = {};

void _handleIncomingRound(dynamic data) {
  if (data == null) return;

  if (data is Map<String, dynamic> && data['id'] is int && data['negotiation'] is int) {
    data = {'negotiation_id': data['negotiation'], 'round': data};
  }

  final negotiationId = data['negotiation_id'];
  final roundJson = data['round'];
  if (negotiationId is! int || roundJson is! Map<String, dynamic>) return;

  final roundId = roundJson['id'];
  if (roundId is int && !_seenRoundIds.add(roundId)) return; // duplicate delivery

  final orderId = roundJson['order_id'];
  final round = NegotiationRound.fromJson(roundJson);

  NegotiationControllerCache.instance
      .controllerFor(negotiationId)
      .applyIncomingRound(round);

  onNegotiationRoundReceived?.call(
      negotiationId, orderId is int ? orderId : null, round);
}
  void _handleStatusChanged(dynamic data) {
    if (data == null) return;

    final negotiationId = data['negotiation_id'];
    final orderId = data['order_id'];

    if (negotiationId == null || negotiationId is! int) {
      if (kDebugMode) {
        print('ClientOrderRealtimeController: unexpected status payload shape: $data');
      }
      return;
    }

    NegotiationControllerCache.instance
        .controllerFor(negotiationId)
        .fetchNegotiationById(negotiationId, force: true);

    onNegotiationStatusChanged?.call(negotiationId, orderId is int ? orderId : null);
  }

  void disconnect() {
    _socket.disconnect();
    _connected = false;
    _activeUserId = null;
    notifyListeners();
  }
}