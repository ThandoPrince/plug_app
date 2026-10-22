import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/const/services/booking_services/fetch_bookings_by_nego_id_api.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';

class NegotiationByIdController extends ChangeNotifier {
  NegotiationModel? negotiation;
  bool isLoading = false;
  String? errorMessage;

  int? _lastFetchedId;

  bool _hasOlder = false;
  bool _loadingOlder = false;
  String? _olderError;

  bool get hasOlderRounds => _hasOlder;
  bool get isLoadingOlder => _loadingOlder;
  bool get hasOlderError => _olderError != null;

  static int _byTime(NegotiationRound a, NegotiationRound b) {
    final t = (a.createdAt ?? DateTime(1970))
        .compareTo(b.createdAt ?? DateTime(1970));
    return t != 0 ? t : (a.id ?? 0).compareTo(b.id ?? 0);
  }

  /// Union by id (incoming wins), oldest -> newest.
  static List<NegotiationRound> _mergeRounds(
    List<NegotiationRound> base,
    List<NegotiationRound> incoming,
  ) {
    final byId = <int, NegotiationRound>{};
    final noId = <NegotiationRound>[];
    for (final r in [...base, ...incoming]) {
      final id = r.id;
      if (id == null) {
        noId.add(r);
      } else {
        byId[id] = r;
      }
    }
    return [...byId.values, ...noId]..sort(_byTime);
  }

  /// No-op if this negotiation is already cached, unless [force] is true.
  /// A forced refresh returns only the latest page, so cached older rounds
  /// are merged back in instead of being thrown away.
  Future<void> fetchNegotiationById(int negotiationId, {bool force = false}) async {
    if (!force &&
        _lastFetchedId == negotiationId &&
        negotiation != null &&
        errorMessage == null) {
      return;
    }

    final previous = _lastFetchedId == negotiationId ? negotiation : null;

    isLoading = negotiation == null || errorMessage != null;
    notifyListeners();

    try {
      final result = await NegotiationByIdApi.fetchNegotiationById(negotiationId);
      final fresh = result?.negotiation;

      if (fresh == null) {
        negotiation = null;
        _hasOlder = false;
      } else if (previous == null) {
        negotiation = fresh;
        _hasOlder = result!.hasMoreRounds; // first load decides this
        _olderError = null;
      } else {
        negotiation = fresh.copyWith(
          rounds: _mergeRounds(previous.rounds ?? [], fresh.rounds ?? []),
        );
      }
      errorMessage = null;
      _lastFetchedId = negotiationId;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ Error fetching negotiation by ID: $e");
        print(stackTrace);
      }
      errorMessage = "Failed to load negotiation details. Please try again later.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the page of rounds before the oldest cached one and returns
  /// the rounds that were actually added (oldest -> newest).
  Future<List<NegotiationRound>> loadOlderRounds(
    int negotiationId, {
    bool retry = false,
  }) async {
    final current = negotiation;
    if (current == null || _loadingOlder || !_hasOlder) return const [];
    if (_olderError != null && !retry) return const [];

    int? oldest;
    for (final r in current.rounds ?? <NegotiationRound>[]) {
      final id = r.id;
      if (id != null && (oldest == null || id < oldest)) oldest = id;
    }
    if (oldest == null) return const [];

    _loadingOlder = true;
    _olderError = null;
    notifyListeners();

    try {
      final result = await NegotiationByIdApi.fetchNegotiationById(
        negotiationId,
        beforeRoundId: oldest,
      );

      // Re-read after the await; a refresh or clear may have run meanwhile.
      final latest = negotiation;
      if (latest == null || _lastFetchedId != negotiationId) return const [];

      final known = {for (final r in latest.rounds ?? <NegotiationRound>[]) r.id};
      final added = (result?.negotiation.rounds ?? <NegotiationRound>[])
          .where((r) => r.id != null && !known.contains(r.id))
          .toList()
        ..sort(_byTime);

      negotiation = latest.copyWith(
        rounds: _mergeRounds(latest.rounds ?? [], added),
      );
      _hasOlder = result?.hasMoreRounds ?? false;
      return added;
    } catch (e) {
      _olderError = e.toString().replaceAll('Exception: ', '');
      return const [];
    } finally {
      _loadingOlder = false;
      notifyListeners();
    }
  }

  /// Merges a round delivered via the realtime socket into the cache.
  void applyIncomingRound(NegotiationRound round) {
    if (negotiation == null) return;

    final rounds = List<NegotiationRound>.from(negotiation!.rounds ?? []);
    final existingIndex = rounds.indexWhere(
      (r) => r.id != null && r.id == round.id,
    );

    if (existingIndex != -1) {
      rounds[existingIndex] = round;
    } else {
      rounds.add(round);
    }

    negotiation = negotiation!.copyWith(rounds: rounds);
    notifyListeners();
  }

  Future<void> refresh(int negotiationId) async {
    await fetchNegotiationById(negotiationId, force: true);
  }

  void clear() {
    negotiation = null;
    errorMessage = null;
    _lastFetchedId = null;
    _hasOlder = false;
    _loadingOlder = false;
    _olderError = null;
    notifyListeners();
  }
}