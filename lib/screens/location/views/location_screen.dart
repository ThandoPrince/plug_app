import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/shimmers/address_list_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';

import 'package:flutter_application_1/global_util/services/controler/patch_default_address_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/widgets/common_error_state.dart';
import 'package:flutter_application_1/screens/location/widgets/address_list_view.dart';
import 'package:flutter_application_1/screens/location/widgets/delete_address_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int? selectedAddressId;

  @override
void initState() {
  super.initState();
}

  AddressClientModel? get _selectedAddress {
    if (selectedAddressId == null) return null;
    final addresses = context.read<AddressClientCtrl>().addresses;
    for (final a in addresses) {
      if (a.id == selectedAddressId) return a;
    }
    return null;
  }

  bool get _isSelectedAddressDefault => _selectedAddress?.isDefault ?? false;

  void _patchDefaultAddress(int addressId) async {
    final patchController = context.read<PatchDefaultAddressController>();
    final addressCtrl = context.read<AddressClientCtrl>();
    final googleMapCtrl = context.read<GoogleMapMarkerController>();

    await patchController.setDefault(addressId);
    addressCtrl.resetCache();
    await addressCtrl.refresh();

    if (!mounted) return;
    await googleMapCtrl.showDefaultAddress(force: true);

    if (!mounted) return;
    FlushbarService.success(context, "Default address updated successfully");
    setState(() {
      selectedAddressId = null;
    });
  }

  Future<void> _deleteAddress(int addressId) async {
    await showDeleteAddressDialog(
      context: context,
      addressId: addressId,
      onDeleted: () async {
        if (!mounted) return;
        setState(() {
          selectedAddressId = null;
        });
      },
    );
  }

  Future<void> _verifyAddress(AddressClientModel address) async {
    await GoRouter.of(context).push<bool>(
      '/existingAddressVerification',
      extra: {
        'client_address_id': address.id,
        'unit_number': address.address.unitNumber,
      },
    );

    if (!mounted) return;
    // Refresh regardless of whether verification finished or was
    // skipped ("Maybe Later"), in case anything changed server-side.
    await _refreshAddresses();
  }

  Future<void> _applyForSuperUser(AddressClientModel address) async {
    await GoRouter.of(context).push<bool>(
      '/existingAddressVerification',
      extra: {
        'client_address_id': address.id,
        'unit_number': address.address.unitNumber,
        // Distinguishes "apply for super user" from the standard
        // "verify this address" flow — the destination screen
        // branches on this to show different copy/steps and call
        // a different submit action.
        'purpose': 'super_user_application',
      },
    );

    if (!mounted) return;
    await _refreshAddresses();
  }

  Future<void> _refreshAddresses() async {
    final addressCtrl = context.read<AddressClientCtrl>();
    final googleMapCtrl = context.read<GoogleMapMarkerController>();

    addressCtrl.resetCache();
    await addressCtrl.refresh();

    if (!mounted) return;
      await googleMapCtrl.showDefaultAddress(force: true);
  }

  @override

Widget build(BuildContext context) {
  const Color primaryColor = Kolors.kPrimary;

  final addressCtrl = context.watch<AddressClientCtrl>();

  final hasSelection = selectedAddressId != null;
  final isDefault = _isSelectedAddressDefault;
  final showActions = hasSelection && !isDefault;

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "My Addresses",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Kolors.kPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (showActions) ...[
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Kolors.kOffWhite.withOpacity(.8)),
            onPressed: () => _deleteAddress(selectedAddressId!),
          ),
          IconButton(
            icon: Icon(Icons.check, color: Kolors.kOffWhite.withOpacity(.8)),
            onPressed: () => _patchDefaultAddress(selectedAddressId!),
          ),
        ],
      ],
    ),
    extendBodyBehindAppBar: true,
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        final id = AuthSessionController.instance.clientId;

        final result = await GoRouter.of(context).push<Object?>(
          '/main_addaddress?email=$id',
        );

        if (!mounted) return;

        if (result == true) {
          await _refreshAddresses();
          return;
        }

        if (result is Map) {
          final addressId = result['address_id'] as int?;
          final unitNumber = result['unit_number'] as String?;

          if (!mounted || addressId == null) return;

          await GoRouter.of(context).push<bool>(
            '/addressVerification',
            extra: {
              'client_address_id': addressId,
              'unit_number': unitNumber,
            },
          );

          if (!mounted) return;
          await _refreshAddresses();
        }
      },
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add_location_alt),
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
        child: _buildBody(addressCtrl),
      ),
    ),
  );
}

Widget _buildBody(AddressClientCtrl controller) {
  // Skeleton only on a true first load, not on pull-to-refresh.
  if (controller.isLoading && controller.addresses.isEmpty) {
    return const AddressListSkeleton();
  }

  if (controller.errorMessage != null && controller.addresses.isEmpty) {
    return CommonErrorState(
      onRefresh: () => controller.refresh(),
      title: "Unable to load addresses",
      message: controller.errorMessage!,
      icon: Icons.location_off_outlined,
    );
  }

  if (controller.addresses.isEmpty) {
    return CommonErrorState(
      onRefresh: () => controller.refresh(),
      title: "No Addresses Yet",
      message: "Add an address using the button below.",
      icon: Icons.location_on_outlined,
    );
  }

  return Column(
    children: [
      Expanded(
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.axis == Axis.vertical &&
                n.metrics.extentAfter < 300 &&
                !controller.hasLoadMoreError) {
              controller.loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            color: Kolors.kPrimary,
            onRefresh: () => controller.refresh(),
            child: AddressListView(
              selectedAddressId: selectedAddressId,
              onSelect: (id) {
                setState(() {
                  selectedAddressId = selectedAddressId == id ? null : id;
                });
              },
              onVerify: _verifyAddress,
              onApplySuperUser: _applyForSuperUser,
            ),
          ),
        ),
      ),
      if (controller.isLoadingMore)
        const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        )
      else if (controller.hasLoadMoreError)
        TextButton(
          onPressed: () => controller.loadMore(retry: true),
          child: const Text(
            "Couldn't load more. Tap to retry",
            style: TextStyle(color: Colors.white70),
          ),
        ),
    ],
  );
}
}