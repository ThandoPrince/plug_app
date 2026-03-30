  import 'package:flutter_dotenv/flutter_dotenv.dart';

String? getFullImageUrl(String? path) {
      final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
  if (path == null || path.isEmpty) return null;

  // Full URL already? Just return it
  if (path.startsWith('http')) return path;

  // Otherwise, prepend your server URL
  return '$baseUrl$path';
}