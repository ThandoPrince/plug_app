import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';

enum AppEventType {
  negotiationRoundCreated,
}

class AppEvent {
  final AppEventType type;
  final int? orderId;
  final int? negotiationId;
  final Map<String, dynamic> payload;

  AppEvent._({
    required this.type,
    this.orderId,
    this.negotiationId,
    required this.payload,
  });

  factory AppEvent.negotiationRoundCreated({
    required int orderId,
    required int negotiationId,
    required Map<String, dynamic> payload,
  }) {
    return AppEvent._(
      type: AppEventType.negotiationRoundCreated,
      orderId: orderId,
      negotiationId: negotiationId,
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
    final negotiationId = int.parse(data['negotiation_id'].toString());

    if (NavigationService.isOnNegotiationScreen(
      int.parse(data['order_id'].toString()),
    )) {
      NavigationService.notifyActiveNegotiation(negotiationId);
      return;
    }

    NegotiationBadgeStore.global.markUnread(negotiationId);
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


