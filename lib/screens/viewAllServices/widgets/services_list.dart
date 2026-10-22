import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/shimmers/services_list_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/common_error_state.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ServicesListWidget extends StatelessWidget {
  const ServicesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const ServicesListSkeleton();
        }

        if (controller.error != null) {
          return CommonErrorState(
            onRefresh: () => controller.refresh(),
            title: "Unable to load services",
            message: controller.error!,
            icon: Icons.handyman_outlined,
          );
        }

        if (controller.services.isEmpty) {
          return CommonErrorState(
            onRefresh: () => controller.refresh(),
            title: "No services available.",
            message: "Please check back later or try a different service.",
            icon: Icons.handyman_outlined,
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Kolors.kOffWhite, Kolors.kOffWhite],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      service.serviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Kolors.kDark,
                      ),
                    ),
                    subtitle: Text(
                      'Active: ${service.activeProviderCount ?? 0}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Kolors.kDark,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Kolors.kDark),
                    onTap: () {
                      context.pushNamed(
                        'viewSPByService',
                        queryParameters: {
                          'serviceId': service.serviceId.toString(),
                          'serviceName': service.serviceName,
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}