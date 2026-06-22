class SPRatingModel {
  final int? id;
  final String? authorType;
  final int? score;
  final String? review;
  final String? createdAt;
  final int? raterClient;
  final int? raterProvider;

  final int? sessionId;
  final String? sessionStatus;

  final int? shipmentId;
  final String? shipmentStatus;

  final int? orderId;
  final String? orderTitle;
  final String? serviceName;

  SPRatingModel({
    this.id,
    this.authorType,
    this.score,
    this.review,
    this.createdAt,
    this.raterClient,
    this.raterProvider,
    this.sessionId,
    this.sessionStatus,
    this.shipmentId,
    this.shipmentStatus,
    this.orderId,
    this.orderTitle,
    this.serviceName,
  });

  factory SPRatingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SPRatingModel();

    return SPRatingModel(
      id: json['id'],
      authorType: json['author_type'],
      score: json['score'],
      review: json['review'],
      createdAt: json['created_at'],
      raterClient: json['rater_client'],
      raterProvider: json['rater_provider'],

      sessionId: json['session']?['session_id'],
      sessionStatus: json['session']?['session_status'],

      shipmentId: json['session']?['shipment']?['shipment_id'],
      shipmentStatus:
          json['session']?['shipment']?['shipment_status'],

      orderId: json['session']
          ?['shipment']
          ?['service_ordered']
          ?['order']
          ?['order_id'],

      orderTitle: json['session']
          ?['shipment']
          ?['service_ordered']
          ?['order']
          ?['title'],

      serviceName: json['session']
          ?['shipment']
          ?['service_ordered']
          ?['order']
          ?['service_required']
          ?['service_name'],
    );
  }

  static List<SPRatingModel> listFromJson(List<dynamic>? data) {
    if (data == null) return [];

    return data
        .map((e) => SPRatingModel.fromJson(e))
        .toList();
  }
}