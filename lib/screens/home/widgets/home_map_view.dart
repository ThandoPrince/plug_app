import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class GoogleMapDemo extends StatefulWidget {
  const GoogleMapDemo({super.key});

  @override
  State<GoogleMapDemo> createState() => _GoogleMapDemoState();
}

class _GoogleMapDemoState extends State<GoogleMapDemo>
    with AutomaticKeepAliveClientMixin<GoogleMapDemo> {
  
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {


      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Preserves state across tab/viewport changes
    
    final mapCtrl = context.read<GoogleMapMarkerController>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      key: const PageStorageKey('googleMap'), // Keeps the map sub-hierarchy alive
      initialCameraPosition: CameraPosition(
        target: GoogleMapMarkerController.fallbackCenter,
        zoom: 14.0,
      ),
      onCameraMoveStarted: () {
  context.read<GoogleMapMarkerController>().unlockClientAnchor();
},
onCameraIdle: () {
  context.read<GoogleMapMarkerController>().lockClientAnchor();
  
},

      markers: mapCtrl.markers, // Automatically renders default + provider marker updates
      onMapCreated: (GoogleMapController controller) {
  final mapCtrl = context.read<GoogleMapMarkerController>();

  mapCtrl.onMapCreated(controller, context);

  // ✅ safe single trigger
  mapCtrl.showDefaultAddress();
},
      // Hides default stock UI elements to keep layout clean for your overlay widgets
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}