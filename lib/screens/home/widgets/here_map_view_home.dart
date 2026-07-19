// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
// import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
// import 'package:provider/provider.dart';
// import 'package:here_sdk/mapview.dart';


// class HereMapDemo extends StatefulWidget {

//   const HereMapDemo({super.key});

//   @override
//   State<HereMapDemo> createState() => _HereMapDemoState();
// }

// class _HereMapDemoState extends State<HereMapDemo>
//     with AutomaticKeepAliveClientMixin<HereMapDemo> {
  
//   bool _isLoading = true;
//   HereMapController? _controller;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final mapCtrl = context.read<HereMapMarkerController>();



    
    
//     await mapCtrl.showDefaultAddress();



      
      

//       if (mounted) setState(() => _isLoading = false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // ✅ now this is valid
//     final mapCtrl = context.watch<HereMapMarkerController>();

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return HereMap(
//       key: const PageStorageKey('hereMap'), // keep map alive
//       onMapCreated: (HereMapController controller) {
//         _controller = controller;
//         mapCtrl.onMapCreated(controller, context);
//       },
//     );

    
//   }
// }


