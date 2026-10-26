import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/shimmers/services_list_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/common_error_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ServicesListWidget extends StatelessWidget {
  const ServicesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            physics: const NeverScrollableScrollPhysics(),
            children: const [ServicesListSkeleton()],
          );
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Kolors.kOffWhite,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      title: Text(
                        service.serviceName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Kolors.kDark,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          'Active Providers: ${service.activeProviderCount ?? 0}',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: Kolors.kDark.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sp,
                        color: Kolors.kDark.withOpacity(0.4),
                      ),
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}