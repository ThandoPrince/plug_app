import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Addresses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White title
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      extendBodyBehindAppBar: true,
      
      // Floating Action Button for adding new address
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final session = context.read<AuthSessionController>();
    final email = session.email;
           // Get email from widget or session
         GoRouter.of(context).push('/main_addaddress?=$email'); 
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_location_alt),
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const SafeArea(
          child: AddressListView(),
        ),
      ),
    );
  }
}