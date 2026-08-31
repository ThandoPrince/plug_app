import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';

class CostAOfService extends StatelessWidget {
  final List<CostOfServiceModel> costs;
  final int? serviceId;

  const CostAOfService({
    super.key,
    required this.costs,
    this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCosts = serviceId == null ? costs : costs.where((cost) => cost.basePrice != null).toList();

    if (filteredCosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
          child: Row(
            children: [
              Icon(Icons.local_offer_outlined, color: Kolors.kPrimary, size: 22),
              SizedBox(width: 10),
              Text(
                "Service Pricing",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF263238),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        ...filteredCosts.map(_buildCostItem),
      ],
    );
  }

  Widget _buildCostItem(CostOfServiceModel cost) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    cost.basePrice != null ? 'R ${cost.basePrice!.toStringAsFixed(2)}' : 'Contact for Price',
                    style: const TextStyle(color: Kolors.kPrimary, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  if (cost.notes != null && cost.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      cost.notes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}