import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/provider_qualifications/views/provider_qualifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/provider_qualifications_client_controller.dart';
// adjust path

Future<void> openProviderQualifications(
  BuildContext context, {
  required int id,
  required int providerServiceId,
}) async {
  final proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Before You Continue",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: const Text(
        "Please note: documents shown here are uploaded directly by the "
        "provider. We do not verify their authenticity or accuracy. "
        "Use your own judgement when reviewing them.",
        style: TextStyle(height: 1.4),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text("I Understand, Continue"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text("Cancel", style: TextStyle(color: Kolors.kPrimary)),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  if (proceed != true || !context.mounted) return;

  final ctrl = context.read<ProviderQualificationsClientController>();
ctrl.clear(); // don't flash the previous provider's documents
ctrl.fetchQualifications(providerServiceId, id);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProviderQualificationsScreen(
      providerServiceId: providerServiceId,
      id: id ,
    ),
  ),
);
}