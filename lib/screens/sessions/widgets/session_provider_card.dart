import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../sp_profile/views copy/viewSP_Profile_Screen.dart';
import 'card_decoration.dart';

class SessionProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final dynamic service;

  static final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

  const SessionProviderCard({
    super.key,
    required this.provider,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    void openProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceProviderScreen(
            id: provider.spProfile!.id ?? 0,
            serviceId: service.serviceRequired.serviceId,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          // Provider Profile Picture
          GestureDetector(
            onTap: openProfile,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Kolors.kPrimary,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  '$baseUrl${provider.profileImage}',
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: GestureDetector(
              onTap: openProfile,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.fullName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),

                  Text(
                    service.serviceRequired.serviceName,
                    style: TextStyle(
                      color: Kolors.kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      if (provider.rating == null) ...[
                        const Text(
                          'New ⭐',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 16,
                        ),
                        Text(
                          ' ${provider.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.call,
                color: Colors.green,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}