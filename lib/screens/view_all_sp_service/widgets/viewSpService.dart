
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

typedef OnProviderTap = void Function(ServiceProviderModel provider);
typedef OnSelectionChanged = void Function(
  List<ServiceProviderModel> selectedProviders,
);

class ProviderListWidget extends StatefulWidget {
  final List<ServiceProviderModel> providers;
  final OnProviderTap? onProviderTap;
  final OnSelectionChanged? onSelectionChanged;

  const ProviderListWidget({
    super.key,
    required this.providers,
    this.onProviderTap,
    this.onSelectionChanged,
  });

  @override
  State<ProviderListWidget> createState() => _ProviderListWidgetState();
}

class _ProviderListWidgetState extends State<ProviderListWidget> {
  static const Color primaryColor = Kolors.kPrimary;

  final List<ServiceProviderModel> _selectedProviders = [];

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'P';

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void _onCheckboxChanged(
    bool? checked,
    ServiceProviderModel provider,
  ) {
    setState(() {
      if (checked == true) {
        if (!_selectedProviders.contains(provider)) {
          _selectedProviders.add(provider);
        }
      } else {
        _selectedProviders.remove(provider);
      }
    });

    widget.onSelectionChanged?.call(_selectedProviders);
  }

  Widget _buildProfileImage(ServiceProviderModel provider) {
    final imageUrl = provider.profileImageUrl;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Kolors.kDark.withOpacity(0.08),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials(provider);
                },
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              )
            : _buildInitials(provider),
      ),
    );
  }

  Widget _buildInitials(ServiceProviderModel provider) {
    return Container(
      color: Kolors.kDark,
      alignment: Alignment.center,
      child: Text(
        _getInitials(provider.fullName ?? 'Provider'),
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Kolors.kOffWhite,
        ),
      ),
    );
  }

  Widget _buildRating(ServiceProviderModel provider) {
    final rating = provider.rating;

    if (rating == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStatus(ServiceProviderModel provider) {
    final isActive = provider.isActive == true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          isActive ? 'Available' : 'Unavailable',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 40,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No service providers available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Kolors.kDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No providers are currently available for this service. '
                'Please try again later or choose another service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: widget.providers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final provider = widget.providers[index];
        final isSelected = _selectedProviders.contains(provider);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isSelected ? 0.08 : 0.04,
                ),
                blurRadius: isSelected ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                widget.onProviderTap?.call(provider);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Selection checkbox
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (checked) =>
                            _onCheckboxChanged(checked, provider),
                        activeColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Profile image
                    _buildProfileImage(provider),

                    const SizedBox(width: 14),

                    // Provider information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (provider.fullName ?? 'Service Provider')
                                .trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Kolors.kDark,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              _buildRating(provider),
                              if (provider.rating != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              _buildActiveStatus(provider),
                            ],
                          ),

                          if (provider.description != null &&
                              provider.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              provider.description!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Details arrow
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withOpacity(0.08)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
