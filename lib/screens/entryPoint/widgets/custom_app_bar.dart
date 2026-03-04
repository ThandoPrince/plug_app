import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/create_service_widget.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/location_widget.dart';
import 'package:flutter_application_1/screens/entryPoint/widgets/notifications_widget.dart';



class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String email;
  const CustomAppBar({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Kolors.kPrimary,
      elevation: 0,
      centerTitle: true,

      leadingWidth: 155, 

      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          
          const LocationWidget(email: ''),  
        ],
      ),

      title: const Text(
        "Plug",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      actions: const [
        CreateServiceWidget(),
        NotificationsWidget(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
