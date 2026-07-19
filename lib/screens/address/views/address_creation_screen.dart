import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/address_creation_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/Widgets/back_to_exit_widget.dart';
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
      child: DoubleBackToExit(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        btnColor: (!ctrl.isValidAddress || ctrl.isLoading) ? Colors.grey : primaryColor,
        btnHieght: 58.h,
        btnWidth: double.infinity,
        radius: 16,
        onTap: (!ctrl.isValidAddress || ctrl.isLoading)
            ? null
            : () async {
                final result = await ctrl.postResidentialAddress(email);

                if (!context.mounted) return;

                // If the operation returns null, extract and display the generated string error layout
                if (result == null) {
  FlushbarService.error(
    context,
    ctrl.error ?? "Failed to add address.",
  );
  return;
}

                // Proceed with successful state migrations
                final data = result["data"];
                if (data == null) return;

                final dynamic rawVerified = data["is_verified"];
                final bool isVerified = (rawVerified == true || rawVerified.toString().toLowerCase() == 'true');
                final int addressId = data["id"] ?? (data["address"] is Map ? data["address"]["id"] : data["address"]) ?? 0;
                final String? unitNumber = data["address"] is Map ? data["address"]["unit_number"] : ctrl.unitNumberController.text;

                if (!isVerified) {
                  _showVerificationDialog(context, addressId, unitNumber);
                } else {
                  FlushbarService.success(context, "Address verified successfully!");
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.only(top: 25.h, left: 20.w, right: 20.w),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        actionsPadding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
        title: Text(
          "Verify Address",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          "Your address is not verified yet.\n\n"
          "Would you like to upload verification documents now?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientBtn(
                text: "VERIFY NOW",
                btnColor: Colors.lightBlueAccent, // Matching your active layout theme
                btnHieght: 50.h,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () {
                  Navigator.pop(context);
                  context.go(
                    "/addressVerificationUpload",
                    extra: {
                      "client_address_id": clientAddressId,
                      "unit_number": unitNumber,
                    },
                  );
                },
              ),
              SizedBox(height: 10.h),
              GradientBtn(
  text: "MAYBE LATER",
  textColor: Colors.black, 
  btnColor: Colors.grey.shade300,
  btnHieght: 50.h,
  btnWidth: double.infinity,
  radius: 12,
  onTap: () {
    Navigator.pop(context);
    _showSuccessOverlay(context);
  },
)
            ],
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
