import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/address_creation_controller.dart';
import 'package:flutter_application_1/screens/auth/views/registration_success_overlay.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:go_router/go_router.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  static final String kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  @override
  Widget build(BuildContext context) {
    final email = GoRouterState.of(context).uri.queryParameters['email'] ?? '';
    const Color primaryColor = Kolors.kPrimary;

    

    return ChangeNotifierProvider(
      create: (_) => AddressCreationController(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Kolors.kPrimary, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Consumer<AddressCreationController>(
              builder: (context, ctrl, child) {
                return Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 40.h),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25.w),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildSearchField(context, ctrl),
                            SizedBox(height: 20.h),
                            if (ctrl.addressController.text.isNotEmpty)
                              _buildAddressPreviewCard(ctrl),
                            SizedBox(height: 20.h),
                            _buildSettingsCard(ctrl),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomButton(context, ctrl, email, primaryColor),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ===============================
  // HEADER
  // ===============================

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            "Your Location",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 8.h),
          const Text(
            "Where should we send your service?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // SEARCH FIELD
  // ===============================

  Widget _buildSearchField(
      BuildContext context, AddressCreationController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        readOnly: true,
        controller: ctrl.addressController,
        onTap: () async {
          Prediction? p = await PlacesAutocomplete.show(
            context: context,
            apiKey: kGoogleApiKey,
            mode: Mode.overlay,
            language: "en",
            components: [Component(Component.country, "za")],
          );

          if (p != null) {
            await ctrl.setAddressFromPrediction(p, kGoogleApiKey);
          }
        },
        decoration: InputDecoration(
          hintText: "Find your address...",
          prefixIcon: const Icon(Icons.search_rounded, color: Kolors.kPrimary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 20.h),
        ),
      ),
    );
  }

  // ===============================
  // ADDRESS PREVIEW
  // ===============================

  Widget _buildAddressPreviewCard(AddressCreationController ctrl) {
    final bool valid = ctrl.isValidAddress;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: valid
              ? Kolors.kPrimary.withOpacity(0.2)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.error_outline,
            color: valid ? Colors.green : Colors.red,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              ctrl.addressController.text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // SETTINGS CARD
  // ===============================

  Widget _buildSettingsCard(AddressCreationController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          /// 🔹 BUILDING TYPE DROPDOWN
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: ctrl.buildingType,
              decoration: const InputDecoration(
                labelText: "Building Type",
              ),
              items: const [
                DropdownMenuItem(
                  value: "house",
                  child: Text("House"),
                ),
                DropdownMenuItem(
                  value: "apartment",
                  child: Text("Apartment"),
                ),
              ],
              onChanged: (value) {
                ctrl.buildingType = value ?? "house";
                ctrl.notifyListeners();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: ctrl.addressType,
              decoration: const InputDecoration(
                labelText: "Address Type",
              ),
              items: const [
                DropdownMenuItem(
                  value: "Residential Address",
                  child: Text("Residential Address"),
                ),
                DropdownMenuItem(
                  value: "Vacation Address",
                  child: Text("Vacation Address"),
                ),
              ],
              onChanged: (value) {
                ctrl.addressType = value ?? "Residential Address";
                ctrl.notifyListeners();
              },
            ),
          ),

          /// 🔹 APARTMENT FIELDS
          if (ctrl.buildingType == "apartment") ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: ctrl.unitNumberController,
                decoration: const InputDecoration(
                  labelText: "Unit Number",
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: ctrl.accessNotesController,
                decoration: const InputDecoration(
                  labelText: "Access Notes (Gate code, floor, etc.)",
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildSwitchTile(
            title: "Owner occupied",
            subtitle: "I am the owner of this property",
            value: ctrl.isOwner,
            onChanged: (val) {
              ctrl.isOwner = val;
              ctrl.notifyListeners();
            },
          ),

          _buildSwitchTile(
            title: "Residence Administrator",
            subtitle: "I manage this household",
            value: ctrl.isHouseAdministrator,
            onChanged: (val) {
              ctrl.isHouseAdministrator = val;
              ctrl.notifyListeners();
            },
          ),

          _buildSwitchTile(
            title: "Default Address",
            subtitle: "Use this for all future bookings",
            value: ctrl.isDefault,
            onChanged: (val) {
              ctrl.isDefault = val;
              ctrl.notifyListeners();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: Kolors.kPrimary,
      title: ReusableText(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }

  // ===============================
  // BOTTOM BUTTON (REFINED FLOW)
  // ===============================

  Widget _buildBottomButton(
    BuildContext context,
    AddressCreationController ctrl,
    String email,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.all(25.w),
      child: GradientBtn(
        text: "SAVE ADDRESS",
        btnColor: (!ctrl.isValidAddress || ctrl.isLoading)
            ? Colors.grey
            : primaryColor,
        btnHieght: 58.h,
        btnWidth: double.infinity,
        radius: 16,
        onTap: (!ctrl.isValidAddress || ctrl.isLoading)
            ? null
            : () async {
                final result = await ctrl.postResidentialAddress(email);

                if (result == null || !context.mounted) return;

                final data = result["data"];

                final bool isVerified = data?["is_verified"] ?? false;

                final int addressId = data?["address"]?["id"] ?? 0;

                final String buildingType =
                    data?["address"]?["building_type"] ?? "house";

                final String? unitNumber = buildingType == "apartment"
                    ? data?["address"]?["unit_number"]
                    : null;

                if (!isVerified) {
                  _showVerificationDialog(
                    context,
                    addressId,
                    unitNumber,
                  );
                } else {
                  _showSuccessOverlay(context);
                }
              },
      ),
    );
  }

  // ===============================
  // VERIFICATION DIALOG
  // ===============================

  void _showVerificationDialog(
    BuildContext context,
    int clientAddressId,
    String? unitNumber,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Verify Address"),
        content: const Text(
          "Your address is not verified yet.\n\n"
          "Would you like to upload verification documents now?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessOverlay(context);
            },
            child: const Text("Maybe Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Navigate to verification screen with client_address_id
              context.go(
                "/addressVerificationUpload",
                extra: {
                  "client_address_id": clientAddressId,
                  "unit_number": unitNumber,
                },
              );
            },
            child: const Text("Verify Now"),
          ),
        ],
      ),
    );
  }

// ===============================
// SUCCESS OVERLAY
// ===============================

  void _showSuccessOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => RegistrationSuccessOverlay(
          onCompleted: () {
            Navigator.of(context).pop();
            context.go('/entryPoint');
          },
        ),
      ),
    );
  }
}
