import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/utils/url_utils.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:flutter_application_1/screens/profile/widgets/full_screen_image_viewer.dart';
import 'package:provider/provider.dart';

class SPBody extends StatefulWidget {
final int id;

  const SPBody({super.key, required this.id});

  @override
  State<SPBody> createState() => _SPBodyState();
}

class _SPBodyState extends State<SPBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProviderByEmailController>(context, listen: false)
          .fetchProviderByEmail(widget.id);
    });
  }

  Widget _buildState({
  required IconData icon,
  required String title,
 required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 90,
            color: Kolors.kPrimary.withOpacity(.7),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderByEmailController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Kolors.kPrimary));
        }

        if (controller.error != null) {
  final error = controller.error!.toLowerCase();

  IconData icon = Icons.cloud_off_outlined;
  String title = "Unable to Load Provider";
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

  return _buildState(
    icon: icon,
    title: title,
    subtitle: subtitle,
  );
}

        final provider = controller.provider;
       if (provider == null) {
  return _buildState(
    icon: Icons.person_search_outlined,
    title: "Provider Not Found",
    subtitle: "We couldn't find the requested provider.",
  );
}
        final imageUrl = getFullImageUrl(provider.profileImage);

        return Stack(
          children: [
            // 1. Top Background Gradient
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
                ),
              ),
            ),

            // 2. Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                children: [
                  // Profile Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                            height: 80), // Space for overlapping image
                        Text(
                          provider.fullName.toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              provider.rating?.toString() ?? "N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(" (Rating)",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child:
                              Divider(thickness: 1, color: Color(0xFFECEFF1)),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              _infoTile(Icons.person_outline_rounded, "Gender",
                                  provider.gender.toString()),
                              _infoTile(Icons.cake_outlined, "Birthday",
                                  provider.dob.toString()),

                              const SizedBox(height: 20),
                              const Text(
                                'About Provider',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                provider.description ??
                                    "No description available.",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueGrey.shade600,
                                  height: 1.5,
                                ),
                              ),
                              

                              // Action Button
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Floating Profile Image
            Positioned(
  top: 50,
  left: 0,
  right: 0,
  child: Center(
    child: GestureDetector(
      onTap: imageUrl != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    image: NetworkImage(imageUrl),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _defaultImage(),
                )
              : _defaultImage(),
        ),
      ),
    ),
  ),
),
          ],
        );
      },
    );
  }

  Widget _defaultImage() {
    return Container(
      width: 110,
      height: 110,
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }

  

 Widget _infoTile(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Kolors.kSecondaryLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: Kolors.kPrimary),
        ),
        const SizedBox(width: 16),

        // ✅ THIS IS THE IMPORTANT FIX
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF455A64),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
