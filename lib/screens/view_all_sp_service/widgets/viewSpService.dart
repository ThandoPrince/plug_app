import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

typedef OnProviderTap = void Function(ServiceProviderModel provider);
typedef OnSelectionChanged = void Function(
    List<ServiceProviderModel> selectedProviders);

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

  // Generate initials from full name for avatar
  String _getInitials(String name) {
    if (name.isEmpty) return 'P';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  void _onCheckboxChanged(bool? checked, ServiceProviderModel provider) {
    setState(() {
      if (checked == true) {
        if (!_selectedProviders.contains(provider)) {
          _selectedProviders.add(provider);
        }
      } else {
        _selectedProviders.remove(provider);
      }
    });
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(_selectedProviders);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No service providers available.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "Please check back later or try a different service.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: widget.providers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final provider = widget.providers[index];
        final isSelected = _selectedProviders.contains(provider);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // 🌟 Highlight selected card with a border using primary color
            side: isSelected ? const BorderSide(color: Kolors.kDark, width: 2) : BorderSide.none,
          ),
          elevation: 3,
          child: Row(
            children: [
              // Checkbox for multi-selection
              Checkbox(
                value: isSelected,
                onChanged: (checked) => _onCheckboxChanged(checked, provider),
                // 🌟 Style the checkbox with primary color
                activeColor: primaryColor,
              ),

              // Expanded tappable card area for details navigation
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (widget.onProviderTap != null) {
                      widget.onProviderTap!(provider);
                    }
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 28,
                          // 🌟 Use primary color for the avatar background
                          backgroundColor: Kolors.kDark,
                          child: Text(
                            _getInitials(provider.fullName),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Kolors.kOffWhite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Provider Name
                              Text(
                                provider.fullName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  // 🌟 Use primary color for the name
                                  color: Kolors.kDark, 
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Email
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      provider.spProfile.emailAddress,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // Phone Number
                              
                            ],
                          ),
                        ),
                        // Navigation Arrow
                        const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}