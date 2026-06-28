import 'package:flutter/material.dart';

class NegotiationBadgeStore extends ChangeNotifier {
  static final NegotiationBadgeStore global = NegotiationBadgeStore();

  final Set<int> _unreadNegotiations = {};

  Set<int> get unreadNegotiations => _unreadNegotiations;

  void markUnread(int negotiationId) {
    _unreadNegotiations.add(negotiationId);
    notifyListeners();
  }

  void clear(int negotiationId) {
    _unreadNegotiations.remove(negotiationId);
    notifyListeners();
  }

  bool isUnread(int negotiationId) {
    return _unreadNegotiations.contains(negotiationId);
  }

  void clearAllForOrder(List<int> negotiationIds) {
    _unreadNegotiations.removeAll(negotiationIds);
    notifyListeners();
  }
}