import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/widgets/qualifications_flow.dart';

class CostAOfService extends StatefulWidget {
  final List<CostOfServiceModel> costs;
  final int? serviceId;

  final int providerId;

  const CostAOfService({
    super.key,
    required this.costs,
      required this.providerId,
    this.serviceId,
  });

  @override
  State<CostAOfService> createState() => _CostAOfServiceState();
}

class _CostAOfServiceState extends State<CostAOfService> {
@override
Widget build(BuildContext context) {
  final filteredCosts = widget.serviceId == null
      ? widget.costs
      : widget.costs.where((cost) => cost.basePrice != null).toList();

  final canViewQualifications =
      widget.providerId != null && widget.serviceId != null;

  // Only hide the whole card if there's nothing at all to show.
  if (filteredCosts.isEmpty && !canViewQualifications) {
    return const SizedBox.shrink();
  }

  return _buildSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredCosts.isNotEmpty) ...[
          const _SectionHeader(
            title: "Service Pricing",
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
        if (canViewQualifications) ...[
          if (filteredCosts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openProviderQualifications(
                context,
                providerServiceId: widget.providerId!,
                id: widget.serviceId!,
              ),
              icon: const Icon(Icons.workspace_premium_outlined, size: 18),
              label: const Text("View Qualifications"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Kolors.kPrimary,
                side: const BorderSide(color: Kolors.kPrimary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildCostItem(CostOfServiceModel cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_outlined, color: Kolors.kPrimary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Base Rate",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
          if (cost.notes != null && cost.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
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
            ),
          ],
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