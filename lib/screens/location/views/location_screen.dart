import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/patch_default_address_controller.dart';
import 'package:flutter_application_1/screens/location/widgets/address_list_view.dart';
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
    Future.microtask(() {
      final session = context.read<AuthSessionController>();

      Provider.of<AddressClientCtrl>(context, listen: false).fetchAddresses();
    });
  }

  void _patchDefaultAddress(int addressId) async {
    final patchController = context.read<PatchDefaultAddressController>();
    final session = context.read<AuthSessionController>();
    final addressCtrl = context.read<AddressClientCtrl>();
    final mapCtrl = context.read<HereMapMarkerController>();
    final googleMapCtrl = context.read<GoogleMapMarkerController>();

    await patchController.setDefault(addressId);
    await addressCtrl.fetchAddresses();
    await mapCtrl.showDefaultAddress();
    await googleMapCtrl.showDefaultAddress();
    FlushbarService.success(
      context,
      "Default address updated successfully",
    );
    setState(() {
      selectedAddressId = null; // reset selection after patch
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Addresses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (selectedAddressId != null)
            IconButton(
              icon: Icon(Icons.check, color: Kolors.kOffWhite.withOpacity(.8)),
              onPressed: () => _patchDefaultAddress(selectedAddressId!),
            )
        ],
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final session = context.read<AuthSessionController>();
          final id = AuthSessionController.instance.clientId;
          GoRouter.of(context).push('/main_addaddress?email=$id');
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_location_alt),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: AddressListView(
            selectedAddressId: selectedAddressId,
            onSelect: (id) {
              setState(() {
                // Toggle selection: if already selected, unselect
                if (selectedAddressId == id) {
                  selectedAddressId = null;
                } else {
                  selectedAddressId = id;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
