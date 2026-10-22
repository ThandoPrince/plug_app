import 'package:flutter/foundation.dart';

/// Tracks unread negotiation-update counts per order (a round was sent,
/// or the negotiation was accepted, while the user wasn't looking at it).
/// Cleared when the user opens that order's detail screen.
class OrderUpdatesBadgeController extends ChangeNotifier {
  final Map<int, int> _unreadCounts = {};

  int countFor(int orderId) => _unreadCounts[orderId] ?? 0;

  void increment(int orderId) {
    _unreadCounts[orderId] = (_unreadCounts[orderId] ?? 0) + 1;
    notifyListeners();
  }

  void clear(int orderId) {
    if (!_unreadCounts.containsKey(orderId)) return;
    _unreadCounts.remove(orderId);
    notifyListeners();
  }

  void clearAll() {
    _unreadCounts.clear();
    notifyListeners();
  }
}