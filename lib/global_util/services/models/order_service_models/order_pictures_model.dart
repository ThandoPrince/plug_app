class ServicePictureModel {
  final int? id;
  final int? orderId;
  final String? imageUrl;
  final DateTime? uploadedAt;

  ServicePictureModel({
    this.id,
    this.orderId,
    this.imageUrl,
    this.uploadedAt,
  });

  factory ServicePictureModel.fromJson(Map<String, dynamic> json) {
    return ServicePictureModel(
      id: json['id'] as int?,
      orderId: json['order'] as int?,
      imageUrl: json['image'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': orderId,
      'image': imageUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }
    String get image {
    // Replace with your server's IP/domain
    return "http://192.168.18.64:8000$imageUrl";
  }
}
