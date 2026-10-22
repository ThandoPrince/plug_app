import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/models/provider_qualification_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/widgets/common_error_state.dart';
import 'package:flutter_application_1/global_util/services/controler/provider_qualifications_client_controller.dart';

import 'package:flutter_application_1/screens/profile/widgets/full_screen_image_viewer.dart';

class ProviderQualificationsScreen extends StatelessWidget {
  final int providerServiceId;
  final int id; // Assuming this is the provider ID

  const ProviderQualificationsScreen({
    super.key,
    required this.providerServiceId,
    required this.id,
  });

  Future<void> _openDocument(BuildContext context, ProviderQualificationModel doc) async {
    final url = doc.documentUrl;
    if (url == null || url.isEmpty) return;

    if (doc.isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(image: NetworkImage(url)),
        ),
      );
      return;
    }

    // PDF / .doc / .docx: no reliable native in-app viewer for all three,
    // so hand off to whatever app/browser the OS resolves for the file.
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
     
      FlushbarService.error(context, "Couldn't open this document.");
    }
  }

  IconData _iconFor(ProviderQualificationModel doc) {
    if (doc.isImage) return Icons.image_outlined;
    if (doc.isPdf) return Icons.picture_as_pdf_outlined;
    if (doc.isDoc) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  String _formatDate(DateTime? d) =>
      d != null ? DateFormat("dd MMM yyyy").format(d) : "-";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Provider Qualifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Kolors.kPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Consumer<ProviderQualificationsClientController>(
            builder: (context, ctrl, _) {
              return Column(
                children: [
                  _buildDisclaimerBanner(),
                  Expanded(child: _buildBody(context, ctrl)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "These documents are uploaded directly by the provider and "
              "are not verified for authenticity by us. Use your own "
              "judgement when reviewing them.",
              style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProviderQualificationsClientController ctrl) {
    if (ctrl.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (ctrl.error != null) {
      return CommonErrorState(
        onRefresh: () => ctrl.fetchQualifications(id, providerServiceId),
        title: "Unable to load qualifications",
        message: ctrl.error!,
        icon: Icons.description_outlined,
      );
    }

    if (ctrl.qualifications.isEmpty) {
      return CommonErrorState(
        onRefresh: () => ctrl.fetchQualifications(id, providerServiceId),
        title: "No Qualifications Uploaded",
        message: "This provider hasn't uploaded any qualification documents yet.",
        icon: Icons.description_outlined,
      );
    }

    return RefreshIndicator(
      color: Kolors.kPrimary,
      onRefresh: () => ctrl.fetchQualifications(id, providerServiceId),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: ctrl.qualifications.length,
        itemBuilder: (context, index) {
          final doc = ctrl.qualifications[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openDocument(context, doc),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Kolors.kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconFor(doc), color: Kolors.kPrimary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.title?.isNotEmpty == true
                                ? doc.title!
                                : doc.documentType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doc.documentType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (doc.issuingBody?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Issued by: ${doc.issuingBody}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (doc.issueDate != null) ...[
                                Icon(Icons.event_outlined, size: 13, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  "Issued ${_formatDate(doc.issueDate)}",
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ],
                          ),
                          if (doc.expiryDate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  size: 13,
                                  color: doc.isExpired ? Colors.red : Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doc.isExpired
                                      ? "Expired ${_formatDate(doc.expiryDate)}"
                                      : "Expires ${_formatDate(doc.expiryDate)}",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: doc.isExpired ? FontWeight.bold : FontWeight.normal,
                                    color: doc.isExpired ? Colors.red : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}