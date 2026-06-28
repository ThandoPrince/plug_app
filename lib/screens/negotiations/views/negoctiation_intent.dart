class NegotiationNavigationIntent {
  static int? orderId;
  static int? negotiationId;

  static void set({
    required int order,
    required int negotiation,
  }) {
    orderId = order;
    negotiationId = negotiation;
  }

  static void clear() {
    orderId = null;
    negotiationId = null;
  }

  static bool get hasIntent =>
      orderId != null && negotiationId != null;
}