import 'package:flutter_dotenv/flutter_dotenv.dart';

class CostOfServiceImageModel {
  final int? id;
  final int? costOfServiceId;
  final String? image;
  final String? imageUrl;
  final DateTime? uploadedAt;

  CostOfServiceImageModel({
    this.id,
    this.costOfServiceId,
    this.image,
    this.imageUrl,
    this.uploadedAt,
  });

  factory CostOfServiceImageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CostOfServiceImageModel();
    }

    return CostOfServiceImageModel(
      id: json['id'] as int?,
      costOfServiceId: json['cost_of_service'] as int?,
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString())
          : null,
    );
  }

  String? get resolvedImageUrl {
    final serverBaseUrl = dotenv.env['MEDIA_BASE_URL']?.trim();

    String? raw = imageUrl?.trim();
    raw = (raw == null || raw.isEmpty) ? image?.trim() : raw;

    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (raw.contains('localhost:8000') &&
          serverBaseUrl != null &&
          serverBaseUrl.isNotEmpty) {
        final uri = Uri.tryParse(raw);
        final path = uri?.path ?? '';
        return _joinUrl(serverBaseUrl, path);
      }
      return raw;
    }

    if (serverBaseUrl != null && serverBaseUrl.isNotEmpty) {
      return _joinUrl(serverBaseUrl, raw);
    }

    return raw;
  }

  static String _joinUrl(String base, String path) {
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return '$normalizedBase$normalizedPath';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cost_of_service': costOfServiceId,
      'image': image,
      'image_url': imageUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }
}