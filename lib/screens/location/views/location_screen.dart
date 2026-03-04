import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/patch_default_address_controller.dart';
import 'package:flutter_application_1/screens/location/widgets/address_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LocationScreen extends StatefulWidget {
  final String email;
  const LocationScreen({super.key, required this.email});

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
      final email = session.email;
      Provider.of<AddressClientCtrl>(context, listen: false)
          .fetchAddresses(email.toString());
    });
  }

  void _patchDefaultAddress(int addressId) async {
   
    final patchController = context.read<PatchDefaultAddressController>();
    final session = context.read<AuthSessionController>();
    final addressCtrl = context.read<AddressClientCtrl>();
    final mapCtrl = context.read<HereMapMarkerController>(); 
    final email = session.email;
    
    
    await patchController.setDefault(addressId, email.toString());
    await addressCtrl.fetchAddresses(email.toString());
    await mapCtrl.showDefaultAddress(email.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Default address updated!")),
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
          final email = session.email;
          GoRouter.of(context)
              .push('/main_addaddress?email=$email'); 
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