import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_1/screens/client_pending_orders_details/widgets/swipeable_gallery.dart';

class ServiceImagesImages extends StatelessWidget {
  final OrderServiceModel booking;
  final Color primaryTextColor;

  const ServiceImagesImages({
    super.key,
    required this.booking,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final pictures = booking.servicePictures;

    if (pictures == null || pictures.isEmpty) {
      return const SizedBox.shrink();
    }

    final images = pictures.map((e) => e.image).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Icon(Icons.photo_library_rounded,
                  size: 20, color: primaryTextColor),
              const SizedBox(width: 10),
              Text(
                "SERVICE Required Photos",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Gallery
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final imgUrl = images[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      
                      MaterialPageRoute(
                        
                        builder: (_) => FullScreenGallery(
                          images: images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.grey.shade100, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Hero(
                        tag: 'service_img_$index',
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildPlaceholder(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                                color: Kolors.kPrimary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) =>
                              _buildPlaceholder(
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({required Widget child}) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: child),
    );
  }
}
