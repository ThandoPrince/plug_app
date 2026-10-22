import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';

class CostOfServiceCard extends StatelessWidget {
  final List<CostOfServiceModel> costs;
  final int? serviceId;

  const CostOfServiceCard({
    super.key,
    required this.costs,
    this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCosts = serviceId == null
        ? costs
        : costs.where((cost) => cost.basePrice != null).toList();

    if (filteredCosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: "Pricing & Offers",
            subtitle: "What this provider charges",
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < filteredCosts.length; i++) ...[
            _buildCostItem(filteredCosts[i]),
            if (i != filteredCosts.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostItem(CostOfServiceModel cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Kolors.kSecondaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined, color: Kolors.kPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cost.basePrice != null
                      ? 'R ${cost.basePrice!.toStringAsFixed(2)}'
                      : 'Contact for Price',
                  style: const TextStyle(
                    color: Kolors.kPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                if (cost.notes != null && cost.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    cost.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }
}