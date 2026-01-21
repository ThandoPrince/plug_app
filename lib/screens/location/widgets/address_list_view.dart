import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart'; // Import kcolors for primary color

import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:provider/provider.dart';

class AddressListView extends StatelessWidget {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color primaryColor = Kolors.kPrimary;
    const Color defaultTextColor = Colors.black87;
    const Color hintColor = Colors.black54;

    return Consumer<AddressClientCtrl>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (controller.errorMessage != null) {
          return Center(
              child: Text(controller.errorMessage!,
                  style: const TextStyle(color: Colors.white)));
        }

        if (controller.addresses.isEmpty) {
          return const Center(
              child: Text("No saved addresses found.",
                  style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final AddressClientModel address = controller.addresses[index];
            final bool isDefault = address.isDefault;

            // debugPrint statements removed for final clean code

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: isDefault ? 8 : 2, // Highlight default address with shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isDefault
                      ? const BorderSide(color: primaryColor, width: 2) // Primary color border
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  
                  // Use primary color for the icon
                  leading: Icon(
                    isDefault ? Icons.home_filled : Icons.location_on_outlined,
                    color: isDefault ? primaryColor : hintColor,
                    size: 30,
                  ),
                  
                  title: Text(
                    address.address.formattedAddress ?? "No address",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isDefault ? FontWeight.bold : FontWeight.w500,
                      color: defaultTextColor,
                    ),
                  ),
                  
                  subtitle: Text(
                    "${address.isOwner ? 'Primary' : 'Secondary'} • ${address.address.country}"
                        .trim(),
                    style: TextStyle(color: hintColor, fontSize: 12),
                  ),
                  
                  trailing: isDefault
                      ? Icon(Icons.check_circle, color: primaryColor)
                      : const Icon(Icons.radio_button_off, color: hintColor),
                  
                  // Wrap the entire ListTile in a GestureDetector or InkWell to handle selection
                  // For simplicity, we'll keep the onTap action absent here, but you'd add:
                  // onTap: () => controller.setDefaultAddress(address.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}