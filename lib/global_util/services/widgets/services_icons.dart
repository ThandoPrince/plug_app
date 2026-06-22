import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ServicesIcons {
  static Widget fromServiceModel({
    required ServiceModel service,
    void Function()? onTap,
    bool isSelected = false,
  }) {
    final icon = _getIconForService(service.serviceName);
    



    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Kolors.kWhite : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Kolors.kPrimary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Kolors.kPrimary : Kolors.kDark,
                  size: isSelected ? 32 : 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service.serviceName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Kolors.kPrimary: Kolors.kDark,
                ),
              ),
            ],
          ),

          // Use activeProviderCount instead of providerCount
          if (service.activeProviderCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    '${service.activeProviderCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  

  static IconData _getIconForService(String name) {
    switch (name.toLowerCase()) {
      case 'makeup technician':
        return Ionicons.brush_outline;
      case 'hairdresser':
        return Ionicons.cut_outline;
      case 'nail technician':
        return Icons.colorize;
      case 'barber':
        return Icons.face;
      case 'car wash':
        return Icons.local_car_wash;
      case 'skincare specialist':
        return Icons.spa_outlined;
      case 'gardener':
        return Ionicons.leaf_outline;
      case 'house cleaner':
        return Icons.cleaning_services_outlined;
      case 'laundry helper':
        return Icons.local_laundry_service;
      case 'plumber':
        return Icons.plumbing;
      case 'electrician':
        return Icons.electrical_services;
      case 'tutor':
        return Icons.menu_book;
      case 'driver':
        return Icons.directions_car;
      case 'babysitter':
        return Icons.child_friendly;
      case 'pet sitter':
        return Icons.pets;
      case 'general labourer':
        return Icons.handyman;
      case 'runner':
        return Icons.run_circle_outlined;
      case 'dj':
        return Icons.music_note;
      case 'personal trainer':
        return Icons.fitness_center;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
