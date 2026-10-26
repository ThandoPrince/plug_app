// Shared by both apps. Copy into each (e.g. lib/common/models/payment_models.dart).

enum PaymentMethod {
  cash('cash'),
  card('card');

  const PaymentMethod(this.apiValue);
  final String apiValue;

  static PaymentMethod fromApi(String? value) =>
      value == 'card' ? PaymentMethod.card : PaymentMethod.cash;
}

enum PaymentStatus {
  pending,
  succeeded,
  failed,
  cashPending,
  cashConfirmed,
  refunded,
  unknown;

  static PaymentStatus fromApi(String? value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'succeeded':
        return PaymentStatus.succeeded;
      case 'failed':
        return PaymentStatus.failed;
      case 'cash_pending':
        return PaymentStatus.cashPending;
      case 'cash_confirmed':
        return PaymentStatus.cashConfirmed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unknown;
    }
  }


  bool get isTerminal =>
      this == succeeded ||
      this == failed ||
      this == cashConfirmed ||
      this == refunded;
}

class PaymentCheckout {
  final String accessCode;
  final String authorizationUrl;
  final String reference;

  const PaymentCheckout({
    required this.accessCode,
    required this.authorizationUrl,
    required this.reference,
  });

  factory PaymentCheckout.fromJson(Map<String, dynamic> json) => PaymentCheckout(
        accessCode: json['access_code']?.toString() ?? '',
        authorizationUrl: json['authorization_url']?.toString() ?? '',
        reference: json['reference']?.toString() ?? '',
      );
}

class Payment {
  final int paymentId;
  final int shipmentId;
  final PaymentMethod method;
  final PaymentStatus status;
  final String amount; // decimal string from the server, e.g. "250" or "250.50"
  final String platformFee;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final String failureReason;
  final PaymentCheckout? checkout;


  final String? sessionStatus;

  const Payment({
    required this.paymentId,
    required this.shipmentId,
    required this.method,
    required this.status,
    required this.amount,
    required this.platformFee,
    required this.failureReason,
    this.createdAt,
    this.paidAt,
    this.checkout,
    this.sessionStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final checkoutJson = json['checkout'];
    return Payment(
      paymentId: (json['payment_id'] as num).toInt(),
      shipmentId: (json['shipment_id'] as num).toInt(),
      method: PaymentMethod.fromApi(json['method']?.toString()),
      status: PaymentStatus.fromApi(json['status']?.toString()),
      amount: json['amount']?.toString() ?? '0',
      platformFee: json['platform_fee']?.toString() ?? '0',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? ''),
      failureReason: json['failure_reason']?.toString() ?? '',
      checkout: checkoutJson is Map<String, dynamic>
          ? PaymentCheckout.fromJson(checkoutJson)
          : null,
      sessionStatus: json['session_status']?.toString(),
    );
  }

  double get amountValue => double.tryParse(amount) ?? 0.0;
  String get amountLabel => 'R ${amountValue.toStringAsFixed(2)}';

  bool get isCard => method == PaymentMethod.card;
  bool get isPaid =>
      status == PaymentStatus.succeeded || status == PaymentStatus.cashConfirmed;

  /// Card chosen, provider has scanned, client has not paid yet.
  bool get readyToPay =>
      isCard &&
      status == PaymentStatus.pending &&
      sessionStatus == 'awaiting_payment';

  /// Once a Paystack transaction exists (or money moved) the price must not change.
  bool get priceLocked => checkout != null || isPaid;
}