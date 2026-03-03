import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'card_decoration.dart';

class ProviderCard extends StatelessWidget {
  final dynamic provider;
  final dynamic service;
  static final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
  const ProviderCard({super.key, required this.provider, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                color: Kolors.kPrimary, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('$baseUrl${provider.profileImage}'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17)),
                Text(service.serviceRequired.serviceName,
                    style: TextStyle(
                        color: Kolors.kPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    Text(' ${provider.rating} • 120 Reviews',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
