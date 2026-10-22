import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/address_a_creation_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';





import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:go_router/go_router.dart';

class MainAddAddressScreen extends StatelessWidget {

  const MainAddAddressScreen({super.key});

  static final String kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  @override
  Widget build(BuildContext context) {
   
    const Color primaryColor = Kolors.kPrimary;

    

    return ChangeNotifierProvider(
      create: (_) => AddressACreationController(),
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
            child: Consumer<AddressACreationController>(
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
                    _buildBottomButton(context, ctrl, primaryColor),
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
            "Add Address",
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
      BuildContext context, AddressACreationController ctrl) {
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
  try {
    await ctrl.setAddressFromPrediction(p, kGoogleApiKey);
  } catch (e) {
    if (!context.mounted) return;
    FlushbarService.error(context, "Couldn't load that address. Please try again.");
  }
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

  Widget _buildAddressPreviewCard(AddressACreationController ctrl) {
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

  Widget _buildSettingsCard(AddressACreationController ctrl) {
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
    AddressACreationController ctrl,
 
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
        final result = await ctrl.postResidentialAddress();

        if (kDebugMode) {
          print("RESULT: $result");
          print("CTRL ERROR: ${ctrl.error}");
        }

        if (!context.mounted) return;

        if (result == null) {
          FlushbarService.error(
            context,
            ctrl.error ?? "Failed to add address.",
          );
          return;
        }

        final data = result["data"];

        if (data == null) {
          FlushbarService.error(
            context,
            "Address was added but the response was invalid.",
          );
          return;
        }

        final dynamic rawVerified = data["is_verified"];

        final bool isVerified =
            rawVerified == true ||
            rawVerified.toString().toLowerCase() == 'true';

        final int addressId =
            data["id"] ??
            (data["address"] is Map
                ? data["address"]["id"]
                : data["address"]) ??
            0;

        final String? unitNumber =
            data["address"] is Map
                ? data["address"]["unit_number"]
                : ctrl.unitNumberController.text;

        // --------------------------------------------------
        // REFRESH ADDRESS DATA
        // --------------------------------------------------

        final addressCtrl =
            context.read<AddressClientCtrl>();

        final mapCtrl =
            context.read<GoogleMapMarkerController>();

        addressCtrl.resetCache();
        await addressCtrl.refresh();

        if (!context.mounted) return;

          await mapCtrl.showDefaultAddress(force: true);

        if (!context.mounted) return;

        // --------------------------------------------------
        // ADDRESS ALREADY VERIFIED
        // --------------------------------------------------

       if (isVerified) {
  await _showVerificationSuccessDialog(context);

  if (!context.mounted) return;

  context.pop(true);
  return;
}

        // --------------------------------------------------
        // ADDRESS NOT VERIFIED
        // --------------------------------------------------
final bool? verificationChoice = await _showVerificationDialog(
  context,
  addressId,
  unitNumber,
);

if (!context.mounted) return;

// ==========================================
// MAYBE LATER
// ==========================================
if (verificationChoice == false) {
  addressCtrl.resetCache();
  await addressCtrl.refresh();

  if (!context.mounted) return;

    await mapCtrl.showDefaultAddress(force: true);

  if (!context.mounted) return;

  // Close MainAddAddressScreen and tell
  // LocationScreen the address was created.
  context.pop(true);
  return;
}

// ==========================================
// VERIFY NOW
// ==========================================
if (verificationChoice == true) {
  // --------------------------------------------------
  // REMOVE MainAddAddressScreen FROM THE STACK

  // So first pop MainAddAddressScreen, then push
  // AddressVerificationScreen from LocationScreen.
  //

  if (!context.mounted) return;

  // Close MainAddAddressScreen first.
  context.pop({
  "address_created": true,
  "open_verification": true,
  "address_id": addressId,
  "unit_number": unitNumber,
});


  return;
}
      },
      ),
    );
  }

  // ===============================
  // VERIFICATION DIALOG
  // ===============================

Future<bool?> _showVerificationDialog(
  BuildContext context,
  int clientAddressId,
  String? unitNumber,
) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (
      dialogContext,
      animation,
      secondaryAnimation,
    ) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==========================================
                // SUCCESS ANIMATION
                // ==========================================
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // SUCCESS TITLE
                // ==========================================
                const Text(
                  "Address Added Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // ==========================================
                // VERIFICATION STATUS
                // ==========================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending_outlined,
                        color: Colors.orange,
                        size: 17,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Verification Pending",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Your address has been saved successfully. "
                  "However, it still needs to be verified.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Would you like to upload your verification "
                  "documents now?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                // ==========================================
                // VERIFY NOW
                // ==========================================
                GradientBtn(
                  text: "VERIFY NOW",
                  btnColor: Colors.lightBlueAccent,
                  btnHieght: 50,
                  btnWidth: double.infinity,
                  radius: 12,
                  onTap: () {
                   

                    Navigator.of(dialogContext).pop(true);
                  },
                ),

                const SizedBox(height: 10),

                // ==========================================
                // MAYBE LATER
                // ==========================================
                GradientBtn(
                  text: "MAYBE LATER",
                  textColor: Colors.black,
                  btnColor: Colors.grey,
                  btnHieght: 50,
                  btnWidth: double.infinity,
                  radius: 12,
                  onTap: () {
                    

                    Navigator.of(dialogContext).pop(false);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },

    // ==========================================
    // DIALOG ENTRANCE ANIMATION
    // ==========================================
    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.85,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

// ===============================
// SUCCESS OVERLAY
// ===============================


Future<void> _showVerificationSuccessDialog(
  BuildContext context,
) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (
      dialogContext,
      animation,
      secondaryAnimation,
    ) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Address Added!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Your address has been successfully "
                  "added and is now ready to use.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                GradientBtn(
                  text: "DONE",
                  btnColor: Kolors.kPrimary,
                  btnHieght: 50,
                  btnWidth: double.infinity,
                  radius: 12,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}


}
