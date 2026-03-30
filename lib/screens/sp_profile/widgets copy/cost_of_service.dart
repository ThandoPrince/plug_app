import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';

class CostOfService extends StatefulWidget {
  final List<CostOfServiceModel> costs;
  final int? serviceId;

  const CostOfService({
    super.key,
    required this.costs,
    this.serviceId,
  });

  @override
  State<CostOfService> createState() => _CostOfServiceState();
}

class _CostOfServiceState extends State<CostOfService> {
  @override
  Widget build(BuildContext context) {
    final filteredCosts = widget.serviceId == null
        ? widget.costs
        : widget.costs
             .where((cost) =>
             cost.basePrice != null)
            .toList();

    if (filteredCosts.isEmpty) {
      return const SizedBox.shrink(); // Hide if no data
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
          child: Row(
            children: [
              Icon(Icons.payments_outlined, color: Kolors.kPrimary, size: 22),
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
        ...filteredCosts.map((cost) => _buildCostItem(cost)),
      ],
    );
  }

  Widget _buildCostItem(CostOfServiceModel cost) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Kolors.kSecondaryLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cost.basePrice != null
                        ? 'R ${cost.basePrice!.toStringAsFixed(2)}'
                        : 'Contact for Price',
                    style: const TextStyle(
                      color: Kolors.kPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBadge(
                  cost.negotiable ? "Negotiable" : "Fixed Price",
                  cost.negotiable ? Colors.green : Colors.blueGrey,
                ),
              ],
            ),
            if (cost.notes != null && cost.notes!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Color(0xFFF1F1F1)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cost.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}