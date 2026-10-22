import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';

enum AppEventType {
  negotiationRoundCreated,
}

class AppEvent {
  final AppEventType type;
  final int? orderId;
  final int? negotiationId;
  final int? roundId;
  final String? senderType;
  final Map<String, dynamic> payload;

  AppEvent._({
    required this.type,
    this.orderId,
    this.negotiationId,
    this.roundId,
    this.senderType,
    required this.payload,
  });

  factory AppEvent.negotiationRoundCreated({
    required int orderId,
    required int negotiationId,
    int? roundId,
    String? senderType,
    required Map<String, dynamic> payload,
  }) {
    return AppEvent._(
      type: AppEventType.negotiationRoundCreated,
      orderId: orderId,
      negotiationId: negotiationId,
      roundId: roundId,
      senderType: senderType,
      payload: payload,
    );
  }
}



class AppEventRouter {
  static final List<void Function(AppEvent)> _handlers = [];

  static void register(void Function(AppEvent event) handler) {
    _handlers.add(handler);
  }

  static void handle(AppEvent event) {
    for (final h in _handlers) {
      h(event);
    }
  }
}

class NegotiationEventHandler {
  static void onRoundCreated(Map<String, dynamic> data) {
    final negotiationId = int.tryParse('${data['negotiation_id']}');
    final orderId = int.tryParse('${data['order_id']}');
    if (negotiationId == null) return;

    final round = data['round'] is Map ? Map<String, dynamic>.from(data['round']) : null;
    final roundId = int.tryParse('${round?['id'] ?? data['round_id']}');
    final senderType = (round?['sender_type'] ?? data['sender_type'])?.toString();

    if (orderId != null && NavigationService.isOnNegotiationScreen(orderId)) {
      NavigationService.notifyActiveNegotiation(negotiationId);
      // fall through: the store ignores rounds for the open sheet anyway
    }

    AppEventRouter.handle(AppEvent.negotiationRoundCreated(
      orderId: orderId ?? 0,
      negotiationId: negotiationId,
      roundId: roundId,
      senderType: senderType,
      payload: data,
    ));
  }
}


class NavigationService {
  static bool _onNegotiationScreen = false;
  static int? _activeOrderId;

  static void setNegotiationScreen(int orderId, bool active) {
    _onNegotiationScreen = active;
    _activeOrderId = orderId;
  }

  static bool isOnNegotiationScreen(int orderId) {
    return _onNegotiationScreen && _activeOrderId == orderId;
  }

  static void notifyActiveNegotiation(int negotiationId) {
    // optional: stream controller / socket refresh trigger
    if (kDebugMode) {
      print("Active negotiation updated: $negotiationId");
    }
  }
}


