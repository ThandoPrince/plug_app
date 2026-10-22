import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NegotiationBadgeStore extends ChangeNotifier {
  static final NegotiationBadgeStore global = NegotiationBadgeStore();
  static const _prefsKey = 'negotiation_last_read_v1';

  final Map<int, int> _lastRead = {};        // negotiationId -> last read round id
  final Map<int, Set<int>> _unread = {};     // negotiationId -> unread round ids
  final Map<int, int> _orderOf = {};         // negotiationId -> orderId
  int? _activeNegotiationId;                 // sheet currently open

  Future<void> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_prefsKey);
    if (raw == null) return;
    (jsonDecode(raw) as Map<String, dynamic>)
        .forEach((k, v) => _lastRead[int.parse(k)] = v as int);
  }

  Future<void> _persist() async => (await SharedPreferences.getInstance())
      .setString(_prefsKey,
          jsonEncode(_lastRead.map((k, v) => MapEntry(k.toString(), v))));

  // ---- queries (keeps your existing API names) ----
  Set<int> get unreadNegotiations =>
      _unread.entries.where((e) => e.value.isNotEmpty).map((e) => e.key).toSet();
  int countFor(int negotiationId) => _unread[negotiationId]?.length ?? 0;
  bool isUnread(int negotiationId) => countFor(negotiationId) > 0;
  int countForOrder(int orderId) => _orderOf.entries
      .where((e) => e.value == orderId)
      .fold(0, (s, e) => s + countFor(e.key));

  // ---- sheet open/close ----
  void setActive(int? negotiationId) => _activeNegotiationId = negotiationId;

  // ---- writes ----
  /// Call for every incoming round (socket) AND when syncing from server data.
  /// Safe to call repeatedly for the same round.
  void registerRound({
    required int negotiationId,
    required int roundId,
    required String? senderType,
    int? orderId,
  }) {
      if (kDebugMode) {
    print('registerRound neg=$negotiationId round=$roundId sender=$senderType '
        'order=$orderId lastRead=${_lastRead[negotiationId]} active=$_activeNegotiationId');
  }
    if (orderId != null) _orderOf[negotiationId] = orderId;
    if (senderType == 'client') return;                    // my own round
    if (roundId <= (_lastRead[negotiationId] ?? 0)) return; // already read
    if (_activeNegotiationId == negotiationId) {            // looking at it now
      markRead(negotiationId, roundId);
      return;
    }
    if (_unread.putIfAbsent(negotiationId, () => {}).add(roundId)) {
      notifyListeners();
    }
  }


  void syncFromRounds(int negotiationId, int? orderId, List<NegotiationRound> rounds) {
  // Anything before my own latest round has been seen by definition.
  final lastClientRound = rounds
      .where((r) => r.senderType == 'client' && r.id != null)
      .fold<int>(0, (m, r) => r.id! > m ? r.id! : m);

  for (final r in rounds) {
    if (r.id == null || r.id! <= lastClientRound) continue;
    registerRound(
      negotiationId: negotiationId,
      roundId: r.id!,
      senderType: r.senderType,
      orderId: orderId,
    );
  }
  if (orderId != null) _orderOf[negotiationId] = orderId;
}

  void markRead(int negotiationId, [int? upToRoundId]) {
    final ids = _unread[negotiationId];
    final maxUnread = (ids == null || ids.isEmpty) ? 0 : ids.reduce((a, b) => a > b ? a : b);
    final newest = upToRoundId ?? maxUnread;
    if (newest > (_lastRead[negotiationId] ?? 0)) {
      _lastRead[negotiationId] = newest;
      _persist();
    }
    if (ids != null && ids.isNotEmpty) {
      ids.clear();
      notifyListeners();
    }
  }

  void clear(int negotiationId) => markRead(negotiationId);

  void clearAllForOrder(List<int> negotiationIds) =>
      negotiationIds.forEach(markRead);
}