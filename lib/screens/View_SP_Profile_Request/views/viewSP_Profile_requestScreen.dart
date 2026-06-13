import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_byemail_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_image_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/widgets/cost_of_service_detail.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/widgets/spdetailsbody.dart';
import 'package:flutter_application_1/screens/booking/views/MultiProviderBookingScreen.dart';
import 'package:provider/provider.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  final int id;
  final int serviceId;

  const ServiceProviderDetailsScreen({
    super.key,
    
    required this.id,
    required this.serviceId,
  });

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  late final ServiceProviderByEmailController spController;
  late final CostOfServiceController costController;
  late final CostOfServiceImageController imageController;

  ServiceProviderModel? loadedProvider;

  @override
  void initState() {
    super.initState();

    spController = ServiceProviderByEmailController();
    costController = CostOfServiceController();
    imageController = CostOfServiceImageController();

    _loadData();
  }

  Future<void> _loadData() async {
    await spController.fetchProviderByEmail(widget.id);

    if (mounted) {
      setState(() {
        loadedProvider = spController.provider;
      });
    }

    await costController.fetchCostByEmailAndService(
      widget.id,
      widget.serviceId,
    );

    final int? costId =
        costController.costs.isNotEmpty ? costController.costs.first.id : null;

    if (costId != null) {
      await imageController.fetchImagesByCostId(costId);
    }
  }

  @override
  void dispose() {
    spController.dispose();
    costController.dispose();
    imageController.dispose();
    super.dispose();
  }

  void _goToBooking(BuildContext context) {
    if (loadedProvider == null) {
      FlushbarService.error(
        context,
        "Provider data is not loaded yet. Please wait.",
      );
      return;
    }

    if (costController.costs.isEmpty) {
      FlushbarService.error(
        context,
        "No pricing found for this provider and selected service.",
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProviderBookingScreen(
          selectedProviders: [loadedProvider!],
          selectedCosts: costController.costs,
          serviceId: widget.serviceId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServiceProviderByEmailController>.value(
          value: spController,
        ),
        ChangeNotifierProvider<CostOfServiceController>.value(
          value: costController,
        ),
        ChangeNotifierProvider<CostOfServiceImageController>.value(
          value: imageController,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: Kolors.kPrimary,
  elevation: 0,
  centerTitle: false,
  iconTheme: const IconThemeData(
    color: Colors.white, // back button color
  ),
  title: const Text(
    "Service Provider Details",
    style: TextStyle(
      fontSize: 18,
      color: Kolors.kOffWhite,
      
    ),
  ),
),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Kolors.kOffWhite],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SPDetailsBody(id: widget.id.toString()),
                const SizedBox(height: 16),

                Consumer<CostOfServiceController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.error != null) {
                      return _buildSectionCard(
                        child: Text(
                          "Error loading cost: ${controller.error}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    return CostOfServiceCard(
                      costs: controller.costs,
                      serviceId: widget.serviceId,
                    );
                  },
                ),

                const SizedBox(height: 18),

                Consumer<CostOfServiceImageController>(
                  builder: (context, controller, _) {
                    return _buildImageGallerySection(controller);
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _goToBooking(context),
          tooltip: 'Book Selected Provider',
          backgroundColor: Kolors.kPrimary,
          child: const Icon(Icons.add_sharp, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildImageGallerySection(CostOfServiceImageController controller) {
    if (controller.isLoading) {
      return _buildSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionHeader(
              title: "Service Photos",
              subtitle: "Loading portfolio images",
            ),
            SizedBox(height: 16),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (controller.images.isEmpty) {
      return _buildSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: "Service Photos",
              subtitle: "Visual examples of providers work",
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(.7)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.photo_library_outlined, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No service images available yet.",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
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
            subtitle: "Visual examples of previous work",
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
                final imageUrl = item.resolvedImageUrl;

                return _ServiceImageCard(
                  imageUrl: imageUrl,
                  imageIndex: index + 1,
                );
              },
            ),
          ),
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
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ServiceImageCard extends StatelessWidget {
  final String? imageUrl;
  final int imageIndex;

  const _ServiceImageCard({
    required this.imageUrl,
    required this.imageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
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
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _imagePlaceholder();
                    },
                  )
                : _imagePlaceholder(),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Portfolio Image $imageIndex',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 42,
          color: Colors.black38,
        ),
      ),
    );
  }
}