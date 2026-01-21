import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/client_address_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMapView extends StatefulWidget {
  final List<ClientAddressModel> savedAddresses;

  const HomeMapView({super.key, required this.savedAddresses});

  @override
  State<HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends State<HomeMapView> {
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    for (var addr in widget.savedAddresses) {
      if (addr.latitude != null && addr.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('address_${_markers.length}'),
            position: LatLng(addr.latitude!, addr.longitude!),
            infoWindow: InfoWindow(
              title: 'Saved Address',
              snippet: addr.formattedAddress ?? '',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        // no assignment if you don't use controller yet
      },
      initialCameraPosition: CameraPosition(
        target: widget.savedAddresses.isNotEmpty
            ? LatLng(widget.savedAddresses.first.latitude ?? 0.0, widget.savedAddresses.first.longitude ?? 0.0)
            : const LatLng(0.0, 0.0),
        zoom: 14.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
    );
  }
}
