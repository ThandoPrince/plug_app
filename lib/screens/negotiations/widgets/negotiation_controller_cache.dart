// negotiation_controller_cache.dart
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_negoID_ctrl.dart';

class NegotiationControllerCache {
  NegotiationControllerCache._();
  static final NegotiationControllerCache instance = NegotiationControllerCache._();

  final Map<int, NegotiationByIdController> _controllers = {};

  NegotiationByIdController controllerFor(int negotiationId) {
    return _controllers.putIfAbsent(negotiationId, () => NegotiationByIdController());
  }

  /// Call after an action that should force a real refetch next time
  /// (e.g. after rejecting/removing a negotiation).
  void invalidate(int negotiationId) {
    _controllers.remove(negotiationId);
  }

  /// Call on logout or when negotiations list is torn down entirely.
  void clearAll() {
    _controllers.clear();
  }
}