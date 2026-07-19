import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'card_decoration.dart';

class SessionProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;

  const SessionProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Service Provider"),
          const Divider(height: 24),
          _detailItem(Icons.person_outline, "Name", provider.fullName),
        
         _detailItem(
  Icons.star_outline,
  "Rating",
  provider.rating != null
      ? provider.rating!.toStringAsFixed(1)
      : "New⭐",
),
        ],
      ),
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
    );
  }

  Widget _detailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
