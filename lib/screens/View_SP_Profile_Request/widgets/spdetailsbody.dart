import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/utils/url_utils.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:provider/provider.dart';

class SPDetailsBody extends StatefulWidget {
  final String email;

  const SPDetailsBody({super.key, required this.email});

  @override
  State<SPDetailsBody> createState() => _SPDetailsBodyState();
}

class _SPDetailsBodyState extends State<SPDetailsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProviderByEmailController>(context, listen: false)
          .fetchProviderByEmail(widget.email);
    });
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text("Error: ${controller.error}"),
              ],
            ),
          );
        }

        final provider = controller.provider;
        if (provider == null) {
          return const Center(child: Text("Provider not found."));
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
                          provider.fullName,
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
                              _infoTile(Icons.alternate_email_rounded, "Email",
                                  provider.spProfile.emailAddress),
                              _infoTile(Icons.person_outline_rounded, "Gender",
                                  provider.gender),
                              _infoTile(Icons.cake_outlined, "Birthday",
                                  provider.dob),

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
