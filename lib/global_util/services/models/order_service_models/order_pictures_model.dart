import 'package:flutter_dotenv/flutter_dotenv.dart';

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
   final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
    return "$baseUrl$imageUrl";
  }
}
