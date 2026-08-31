import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

import 'package:flutter_application_1/global_util/services/controler/cost_of_service_byemail_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_image_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_rating_controller.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';

import 'package:flutter_application_1/screens/View_SP_Profile_Request/widgets/spdetailsbody.dart';
import 'package:flutter_application_1/screens/profile/widgets/full_screen_image_viewer.dart';
import 'package:flutter_application_1/screens/sp_profile/widgets%20copy/cost_of_service.dart';
import 'package:provider/provider.dart';

class ServiceProviderScreen extends StatefulWidget {
  final int id;
  final int serviceId;

  const ServiceProviderScreen({
    super.key,
    required this.id,
    required this.serviceId,
  });

  @override
  State<ServiceProviderScreen> createState() => _ServiceProviderScreenScreenState();
}

class _ServiceProviderScreenScreenState extends State<ServiceProviderScreen> {
  late final ServiceProviderByEmailController spController;
  late final CostOfServiceController costController;
  late final CostOfServiceImageController imageController;

  ServiceProviderModel? loadedProvider;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();

    spController = ServiceProviderByEmailController();
    costController = CostOfServiceController();
    imageController = CostOfServiceImageController();

    _loadData();
  }

  Future<void> _loadData() async {
    // Was calling fetchProviderByEmail twice — that duplicate call was
    // flipping isLoading true/false right after it had already settled,
    // which is part of what caused visible flicker.
    await Future.wait([
      context.read<SPRatingController>().fetchRatings(widget.id),
      spController.fetchProviderByEmail(widget.id),
    ]);

    if (!mounted) return;

    loadedProvider = spController.provider;

    await costController.fetchCostByEmailAndService(
      widget.id,
      widget.serviceId,
    );

    final int? costId =
        costController.costs.isNotEmpty ? costController.costs.first.id : null;

    if (costId != null) {
      await imageController.fetchImagesByCostId(costId);
    }

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    spController.dispose();
    costController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServiceProviderByEmailController>.value(value: spController),
        ChangeNotifierProvider<CostOfServiceController>.value(value: costController),
        ChangeNotifierProvider<CostOfServiceImageController>.value(value: imageController),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Kolors.kPrimary,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Service Provider Info",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _isInitialLoading
              ? const _ScreenSkeleton()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SPDetailsBody(id: widget.id.toString()),
                      const SizedBox(height: 10),
                      Consumer<CostOfServiceController>(
                        builder: (context, controller, _) {
                          // FIX: was `!= Null` (the Type) three times in a row,
                          // which is always true regardless of the real value
                          // and permanently hid the pricing card. Now a single
                          // correct null-check, with the message picked based
                          // on the actual error text — same pattern used in
                          // SPDetailsBody.
                          if (controller.error != null) {
                            final error = controller.error!.toLowerCase();
                            IconData icon = Icons.cloud_off_outlined;
                            String title = "Unable to Load Pricing";
                            String subtitle = "Something went wrong. Please try again.";

                            if (error.contains("socket") ||
                                error.contains("network") ||
                                error.contains("internet")) {
                              icon = Icons.wifi_off;
                              title = "No Internet Connection";
                              subtitle = "Please connect to the internet and try again.";
                            } else if (error.contains("timeout")) {
                              icon = Icons.access_time;
                              title = "Request Timed Out";
                              subtitle = "The server took too long to respond.";
                            } else if (error.contains("500") ||
                                error.contains("502") ||
                                error.contains("503") ||
                                error.contains("server")) {
                              icon = Icons.cloud_off_outlined;
                              title = "Server Unavailable";
                              subtitle = "We're unable to reach the server right now.";
                            }

                            return _buildStateCard(icon: icon, title: title, subtitle: subtitle);
                          }

                          return CostAOfService(
                            costs: controller.costs,
                            serviceId: widget.serviceId,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Consumer<CostOfServiceImageController>(
                        builder: (context, controller, _) => _buildImageGallerySection(controller),
                      ),
                      const SizedBox(height: 10),
                      Consumer<SPRatingController>(
                        builder: (context, controller, _) {
                          if (controller.ratings.isEmpty) {
                            return _buildSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionHeader(
                                    title: "Ratings & Reviews",
                                    subtitle: "Recent customer feedback",
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star_outline_rounded, color: Colors.amber, size: 22),
                                        const SizedBox(width: 8),
                                        Text(
                                          "New • No ratings yet",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(
                                  title: "Ratings & Reviews",
                                  subtitle: "Recent customer feedback",
                                ),
                                const SizedBox(height: 16),
                                ...controller.ratings.map(
                                  (rating) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 18),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${rating.score ?? 0}/5",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if ((rating.serviceName ?? "").isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Kolors.kPrimary.withOpacity(.08),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                rating.serviceName!,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          if ((rating.review ?? "").trim().isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              rating.review!,
                                              style: const TextStyle(color: Colors.black87),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImageGallerySection(CostOfServiceImageController controller) {
    if (controller.images.isEmpty) {
      return _buildSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: "Service Photos",
              subtitle: "Visual examples of provider's work",
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.photo_library_outlined, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No service photos yet — this provider hasn't uploaded a portfolio.",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: "Service Photos",
            subtitle: "See their previous work",
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = controller.images[index];
                return _ServiceImageCard(imageUrl: item.resolvedImageUrl, imageIndex: index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateCard({required IconData icon, required String title, required String subtitle}) {
    return _buildSectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
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

class _ServiceImageCard extends StatelessWidget {
  final String? imageUrl;
  final int imageIndex;

  const _ServiceImageCard({required this.imageUrl, required this.imageIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () {
          if (imageUrl == null || imageUrl!.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenImageViewer(image: NetworkImage(imageUrl!)),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl != null && imageUrl!.trim().isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.white,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Portfolio Image $imageIndex',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.white,
      child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 42, color: Colors.black38)),
    );
  }
}

class _ScreenSkeleton extends StatefulWidget {
  const _ScreenSkeleton();

  @override
  State<_ScreenSkeleton> createState() => _ScreenSkeletonState();
}

class _ScreenSkeletonState extends State<_ScreenSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({double? width, double height = 16, double radius = 10}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35 + 0.25 * _controller.value),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      child: Column(
        children: [
          _box(width: 110, height: 110, radius: 55),
          const SizedBox(height: 20),
          _box(width: 180, height: 20),
          const SizedBox(height: 10),
          _box(width: 100, height: 14),
          const SizedBox(height: 24),
          _box(width: double.infinity, height: 140, radius: 20),
          const SizedBox(height: 16),
          _box(width: double.infinity, height: 90, radius: 20),
          const SizedBox(height: 16),
          _box(width: double.infinity, height: 200, radius: 20),
        ],
      ),
    );
  }
}