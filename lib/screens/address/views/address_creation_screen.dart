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
                    // --- Header ---
                    Padding(
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
                    ),

                    SizedBox(height: 40.h),

                    // --- Content Area ---
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 25.w),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // 1. Search Field Card
                            _buildSearchField(context, ctrl),

                            SizedBox(height: 20.h),

                            // 2. Selected Address Preview (Animated Visibility)
                           if (ctrl.addressController.text.isNotEmpty)
  _buildAddressPreviewCard(ctrl),


                            SizedBox(height: 20.h),

                            // 3. Address Settings Card
                            _buildSettingsCard(ctrl),
                          ],
                        ),
                      ),
                    ),

                    // --- Bottom Action Button ---
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

  // --- UI Components ---

  Widget _buildSearchField(
      BuildContext context, AddressCreationController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
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
          suffixIcon:
              const Icon(Icons.my_location, color: Colors.grey, size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 20.h),
        ),
      ),
    );
  }

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.error_outline,
          color: valid ? Colors.green : Colors.red,
          size: 24,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableText(
                text: valid
                    ? "Confirmed Address"
                    : "Incomplete Address",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                ctrl.addressController.text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              if (!valid) ...[
                SizedBox(height: 6.h),
                Text(
                  "Please select a full street-level address.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildSettingsCard(AddressCreationController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: "Owner occupied",
            subtitle: "I am the owner of this property",
            value: ctrl.isOwner,
            onChanged: (val) {
              ctrl.isOwner = val;
              ctrl.notifyListeners();
            },
          ),
          Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 20,
              endIndent: 20),
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

  Widget _buildBottomButton(
    BuildContext context,
    AddressCreationController ctrl,
    String email,
    Color primaryColor,
  ) {
  return Container(
    padding: EdgeInsets.all(25.w),
    decoration: BoxDecoration(
      color: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
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
              final success = await ctrl.postResidentialAddress(email);

              if (success && context.mounted) {
                
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
            },
    ),
  );
}

}
