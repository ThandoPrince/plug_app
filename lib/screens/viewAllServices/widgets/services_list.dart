import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/screens/view_all_sp_service/views/view_sp_ass_service_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ServicesListWidget extends StatelessWidget {
  const ServicesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(child: Text('Error: ${controller.error}'));
        }

        if (controller.services.isEmpty) {
           return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handyman_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No services available.",
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

        return Container(
          decoration: const BoxDecoration(
    gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight], // Deep brand gradient
                  ),
  ),
          child: ListView.builder(
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
          
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
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
                color: Kolors.kDark, // make text visible on gradient
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
