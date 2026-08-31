import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/shimmers/address_list_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/screens/address_household/views/household_members_view.dart';
import 'package:provider/provider.dart';

class AddressListView extends StatelessWidget {
  final int? selectedAddressId;
  final Function(int) onSelect;
  final Function(AddressClientModel) onVerify;
  final Function(AddressClientModel) onApplySuperUser;

  const AddressListView({
    super.key,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onVerify,
    required this.onApplySuperUser,
  });

  // =========================
  // SUPER ADMIN MENU
  // =========================
  void _handleSuperUserTap(
    BuildContext context,
    int addressId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text(
                    "View Household",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HouseholdMembersView(
                          clientAddressId: addressId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // SUPER ADMIN BADGE
  // =========================
  Widget _buildSuperAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.amber.shade700,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 12,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            "SUPER ADMIN",
            style: TextStyle(
              color: Colors.amber.shade800,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // APPLY FOR SUPER ADMIN
  // (only shown when address is verified but not yet super user)
  // =========================
  Widget _buildApplySuperUserBadge(AddressClientModel address) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onApplySuperUser(address),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: Kolors.kPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 13,
              color: Kolors.kPrimary,
            ),
            const SizedBox(width: 3),
            Text(
              "Apply for Super Admin",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Kolors.kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // VERIFIED BADGE
  // =========================
  Widget _buildVerificationBadge(
    BuildContext context,
    AddressClientModel address,
    bool isVerified,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isVerified ? null : () => onVerify(address),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: (isVerified ? Colors.green : Colors.orange)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.error_outline,
              size: 14,
              color: isVerified ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 3),
            Text(
              isVerified ? "Verified" : "Verify Now",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isVerified ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ADDRESS TITLE
  // =========================
  Widget _buildAddressTitle({
    required AddressClientModel address,
    required bool isDefault,
    required bool isSuperUser,
    required bool isVerified,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          address.address.formattedAddress ?? "No address",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isDefault ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
            decoration: TextDecoration.none,
          ),
        ),

        // SUPER ADMIN badge for existing super users.
        if (isSuperUser) ...[
          const SizedBox(height: 6),
          _buildSuperAdminBadge(),
        ]
        // Not a super user yet, but address is already verified —
        // offer the application path.
        else if (isVerified) ...[
          const SizedBox(height: 6),
          _buildApplySuperUserBadge(address),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color hintColor = Colors.black54;

    return Consumer<AddressClientCtrl>(
      builder: (context, controller, child) {
        // =========================
        // LOADING
        // =========================
        if (controller.isLoading) {
          return const AddressListSkeleton();
        }

        // =========================
        // ERROR
        // =========================
        if (controller.errorMessage != null) {
          return Center(
            child: Text(
              controller.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }

        // =========================
        // EMPTY
        // =========================
        if (controller.addresses.isEmpty) {
          return const Center(
            child: Text(
              "No saved addresses found.",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }

        // =========================
        // ADDRESS LIST
        // =========================
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final address = controller.addresses[index];

            final bool isSelected = selectedAddressId == address.id;
            final bool isDefault = address.isDefault || isSelected;
            final bool isVerified = address.address.isVerified;
            final bool isSuperUser = address.isSuperUser;

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Card(
                elevation: isDefault ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isDefault
                      ? const BorderSide(
                          color: primaryColor,
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  // =========================
                  // ADDRESS ICON
                  // =========================
                  leading: Icon(
                    isDefault
                        ? Icons.home_filled
                        : Icons.location_on_outlined,
                    color: isDefault ? primaryColor : hintColor,
                    size: 30,
                  ),

                  // =========================
                  // ADDRESS + SUPER ADMIN / APPLY BADGE
                  // =========================
                  title: _buildAddressTitle(
                    address: address,
                    isDefault: isDefault,
                    isSuperUser: isSuperUser,
                    isVerified: isVerified,
                  ),

                  // =========================
                  // ADDRESS DETAILS
                  // =========================
                  subtitle: Padding(
                    padding: const EdgeInsets.only(
                      top: 7,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${address.isOwner ? 'Primary' : 'Secondary'} • ${address.address.country}"
                                .trim(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // =========================
                        // VERIFICATION
                        // =========================
                        _buildVerificationBadge(
                          context,
                          address,
                          isVerified,
                        ),
                      ],
                    ),
                  ),

                  // =========================
                  // TRAILING
                  // =========================
                  trailing: isSuperUser
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Selected/default indicator
                            isDefault
                                ? const Icon(
                                    Icons.check_circle,
                                    color: primaryColor,
                                  )
                                : const Icon(
                                    Icons.radio_button_off,
                                    color: hintColor,
                                  ),

                            const SizedBox(width: 6),

                            // Household menu
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _handleSuperUserTap(
                                context,
                                address.id,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      : isDefault
                          ? const Icon(
                              Icons.check_circle,
                              color: primaryColor,
                            )
                          : const Icon(
                              Icons.radio_button_off,
                              color: hintColor,
                            ),

                  // =========================
                  // SELECT ADDRESS
                  // =========================
                  onTap: () => onSelect(address.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}