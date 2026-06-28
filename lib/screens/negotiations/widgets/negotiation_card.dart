import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';

class NegotiationCard extends StatelessWidget {
  final NegotiationModel negotiation;

  const NegotiationCard({
    super.key,
    required this.negotiation,
  });

  String _formatDate(DateTime? dt) =>
      dt != null ? DateFormat('dd MMM yyyy').format(dt) : 'N/A';

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return "?";
    final parts = fullName.split(" ");
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(negotiation.createdAt);

    final profilePath =
        negotiation.providerForNegotiation?.provider.profileImage;

    final String coreUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';
    final profileUrl =
        profilePath != null ? "$coreUrl$profilePath" : null;

    final fullName =
        negotiation.providerForNegotiation?.provider.fullName;

    final negotiationId = negotiation.negotiationId;

    return Consumer<NegotiationBadgeStore>(
      builder: (context, store, _) {
        final isUnread = negotiationId != null &&
            store.isUnread(negotiationId);

        return Stack(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: profileUrl != null
                          ? NetworkImage(profileUrl)
                          : null,
                      child: profileUrl == null
                          ? Text(
                              _getInitials(fullName),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Kolors.kDark,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName ?? "Unknown Provider",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            "Status: ${negotiation.status ?? 'Pending'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Proposed: R${negotiation.proposedPrice?.toStringAsFixed(2) ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔴 BADGE (NEW)
            if (isUnread)
              Positioned(
                right: 20,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}