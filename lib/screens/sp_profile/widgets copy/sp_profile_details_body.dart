import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/utils/url_utils.dart';
import 'package:flutter_application_1/global_util/services/controler/provider_qualifications_client_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_rating_controller.dart';
import 'package:flutter_application_1/screens/profile/widgets/full_screen_image_viewer.dart';
import 'package:flutter_application_1/screens/provider_qualifications/views/provider_qualifications_screen.dart';
import 'package:provider/provider.dart';

class SPProfileDetailsBody extends StatelessWidget {
  final String id;
  final int providerServiceId;

  const SPProfileDetailsBody({super.key, required this.id, required this.providerServiceId,});

  int? get _providerServiceId => providerServiceId ?? int.tryParse(id);



  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderByEmailController>(
      builder: (context, controller, _) {
        final provider = controller.provider;

        if (provider == null) {
          return const SizedBox.shrink();
        }

        final imageUrl = getFullImageUrl(provider.profileImage);
        final reviewCount = context.watch<SPRatingController>().ratings.length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 190,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Container(
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
                    const SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            provider.fullName.toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Tooltip(
                          message: "Verified Provider",
                          child: Icon(Icons.verified,
                              color: Kolors.kPrimary, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Trusted local service provider",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating?.toString() ?? "N/A",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reviewCount > 0 ? "($reviewCount reviews)" : "(new provider)",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Divider(thickness: 1, color: Color(0xFFECEFF1)),
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
                            provider.description ?? "No description available.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey.shade600,
                              height: 1.5,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
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
                              errorBuilder: (context, error, stackTrace) => _defaultImage(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade300,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF455A64))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}