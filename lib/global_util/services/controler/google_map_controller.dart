// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';

// import '../models/sp_live_location_model.dart';
// import '../models/client_models/address_client_model.dart';
// import '../controler/sp_add_by_id_ctrl.dart';
// import '../controler/def_add_controller.dart';

// class GoogleMapMarkerController extends ChangeNotifier {
//   // ----------------------------
//   // Selected Service & Provider
//   // ----------------------------
//   int? _selectedServiceId;
//   int? get selectedServiceId => _selectedServiceId;

//   SPLiveLocationModel? _selectedProvider;
//   SPLiveLocationModel? get selectedProvider => _selectedProvider;

//   // ----------------------------
//   // Map defaults
//   // ----------------------------
//   static const LatLng fallbackCenter = LatLng(-26.2041, 28.0473);

//   GoogleMapController? _mapController;

//   // Marker store for Google Maps
//   final Map<MarkerId, Marker> _markers = {};
//   Map<MarkerId, Marker> get markers => Map.unmodifiable(_markers);

//   final List<SPLiveLocationModel> _visibleProviders = [];
//   List<SPLiveLocationModel> get visibleProviders => List.unmodifiable(_visibleProviders);

//   BitmapDescriptor? _defaultIcon;
//   BitmapDescriptor? _spIcon;

//   MarkerId? _defaultMarkerId;

//   // ----------------------------
//   // Controllers
//   // ----------------------------
//   final SpAddressControllerByID spAddrCtrl;
//   final DefAddController defAddCtrl;

//   GoogleMapMarkerController({
//     required this.spAddrCtrl,
//     required this.defAddCtrl,
//   });

//   // ----------------------------
//   // Map initialization
//   // ----------------------------
//   Future<void> onMapCreated(
//     GoogleMapController controller,
//     BuildContext context,
//   ) async {
//     _mapController = controller;

//     await _ensureMarkerImagesLoaded();
//     await restoreMarkers();

//     final session = context.read<AuthSessionController>();
//     final email = session.email;

//     if (email != null && email.isNotEmpty) {
//       await showDefaultAddress(email);
//     } else {
//       debugPrint("No logged-in email found for default address.");
//       await _focusOnFallback();
//     }
//   }

//   // ----------------------------
//   // Marker images
//   // ----------------------------
//   Future<BitmapDescriptor> _loadMarkerImage(String assetPath, int width) async {
//     final ByteData data = await rootBundle.load(assetPath);
//     final codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetWidth: width,
//     );
//     final frame = await codec.getNextFrame();
//     final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
//   }

//   Future<void> _ensureMarkerImagesLoaded() async {
//     _defaultIcon ??= await _loadMarkerImage("assets/icons/default_marker.png", 96);
//     _spIcon ??= await _loadMarkerImage("assets/icons/sp_marker.png", 100);
//   }

//   // ----------------------------
//   // Service selection
//   // ----------------------------
//   void selectService(int serviceId) {
//     _selectedServiceId = serviceId;
//     notifyListeners();
//   }

//   void clearSelection() {
//     _selectedServiceId = null;
//     _selectedProvider = null;
//     _clearSpMarkers();
//     notifyListeners();
//   }

//   // ----------------------------
//   // Default address
//   // ----------------------------
//   Future<void> showDefaultAddress(String email) async {
//     if (_mapController == null) return;

//     await defAddCtrl.fetchAddresses(email);

//     if (defAddCtrl.addresses.isEmpty) {
//       await _focusOnFallback();
//       return;
//     }

//     AddressClientModel defaultAddr = defAddCtrl.addresses.firstWhere(
//       (a) => a.isDefault == true,
//       orElse: () => defAddCtrl.addresses.first,
//     );

//     final coords = LatLng(
//       defaultAddr.address.latitude ?? fallbackCenter.latitude,
//       defaultAddr.address.longitude ?? fallbackCenter.longitude,
//     );

//     // remove previous default marker
//     if (_defaultMarkerId != null) {
//       _markers.remove(_defaultMarkerId);
//     }

//     _defaultMarkerId = const MarkerId("default_address");

//     _markers[_defaultMarkerId!] = Marker(
//       markerId: _defaultMarkerId!,
//       position: coords,
//       icon: _defaultIcon ?? BitmapDescriptor.defaultMarker,
//       anchor: const Offset(0.5, 1.0),
//       zIndex: 10,
//       infoWindow: const InfoWindow(title: "Default Address"),
//     );

//     notifyListeners();

//     await Future.delayed(const Duration(milliseconds: 300));
//     await _focusCamera(coords);
//   }

//   // ----------------------------
//   // Service provider markers
//   // ----------------------------
//   Future<void> showServiceProviders(int serviceId) async {
//     if (_mapController == null) return;

//     await _ensureMarkerImagesLoaded();

//     _clearSpMarkers();
//     _visibleProviders.clear();
//     _selectedServiceId = serviceId;
//     _selectedProvider = null;

//     await spAddrCtrl.fetchAddressesByService(serviceId);

//     for (final sp in spAddrCtrl.addresses) {
//       if (sp.latitude == null || sp.longitude == null) continue;

//       final providerId = sp.providerId;
//       final markerId = MarkerId("provider_$providerId");
//       final position = LatLng(sp.latitude!, sp.longitude!);

//       _markers[markerId] = Marker(
//         markerId: markerId,
//         position: position,
//         icon: _spIcon ?? BitmapDescriptor.defaultMarker,
//         anchor: const Offset(0.5, 1.0),
//         infoWindow: InfoWindow(
//           title: sp.providerName ?? "Service Provider",
//           snippet: "Tap for details",
//         ),
//         onTap: () => onMarkerTap(providerId!),
//       );

//       _visibleProviders.add(sp);
//     }

//     notifyListeners();
//     await _fitMarkersToSPBounds();
//   }

//   void removeSpMarkers() {
//     final idsToRemove = _markers.keys
//         .where((id) => id.value.startsWith("provider_"))
//         .toList();

//     for (final id in idsToRemove) {
//       _markers.remove(id);
//     }

//     _selectedServiceId = null;
//     _selectedProvider = null;

//     notifyListeners();
//   }

//   Future<void> restoreMarkers() async {
//     if (_mapController == null) return;

//     // In google_maps_flutter, markers are recreated from state.
//     // Since _markers already stores them, just notify.
//     notifyListeners();

//     if (_visibleProviders.isNotEmpty) {
//       await _fitMarkersToSPBounds();
//     } else if (_defaultMarkerId != null && _markers[_defaultMarkerId!] != null) {
//       await _focusCamera(_markers[_defaultMarkerId!]!.position);
//     }
//   }

//   void onMarkerTap(int providerId) {
//     try {
//       _selectedProvider = _visibleProviders.firstWhere(
//         (p) => p.providerId == providerId,
//       );
//       notifyListeners();
//     } catch (_) {
//       debugPrint("Provider not found for tapped marker: $providerId");
//     }
//   }

//   // ----------------------------
//   // Camera helpers
//   // ----------------------------
//   Future<void> _focusCamera(LatLng coords) async {
//     if (_mapController == null) return;

//     await _mapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: coords,
//           zoom: 14.5,
//         ),
//       ),
//     );
//   }

//   Future<void> _focusOnFallback() async {
//     if (_mapController == null) return;

//     await _mapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         const CameraPosition(
//           target: fallbackCenter,
//           zoom: 11,
//         ),
//       ),
//     );
//   }

//   Future<void> _fitMarkersToSPBounds() async {
//     if (_mapController == null || _visibleProviders.isEmpty) return;

//     double minLat = _visibleProviders.first.latitude!;
//     double maxLat = _visibleProviders.first.latitude!;
//     double minLng = _visibleProviders.first.longitude!;
//     double maxLng = _visibleProviders.first.longitude!;

//     for (final sp in _visibleProviders) {
//       minLat = minLat < sp.latitude! ? minLat : sp.latitude!;
//       maxLat = maxLat > sp.latitude! ? maxLat : sp.latitude!;
//       minLng = minLng < sp.longitude! ? minLng : sp.longitude!;
//       maxLng = maxLng > sp.longitude! ? maxLng : sp.longitude!;
//     }

//     // padding similar to your HERE version
//     const double padding = 0.002;
//     minLat -= padding;
//     maxLat += padding;
//     minLng -= padding;
//     maxLng += padding;

//     final bounds = LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );

//     await _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(bounds, 80),
//     );
//   }

//   Future<void> fitAllMarkersToBounds() async {
//     if (_mapController == null || _markers.isEmpty) return;

//     final positions = _markers.values.map((m) => m.position).toList();

//     double minLat = positions.first.latitude;
//     double maxLat = positions.first.latitude;
//     double minLng = positions.first.longitude;
//     double maxLng = positions.first.longitude;

//     for (final p in positions) {
//       if (p.latitude < minLat) minLat = p.latitude;
//       if (p.latitude > maxLat) maxLat = p.latitude;
//       if (p.longitude < minLng) minLng = p.longitude;
//       if (p.longitude > maxLng) maxLng = p.longitude;
//     }

//     final bounds = LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );

//     await _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(bounds, 80),
//     );
//   }

//   // ----------------------------
//   // Clear / dispose
//   // ----------------------------
//   void _clearSpMarkers() {
//     final idsToRemove = _markers.keys
//         .where((id) => id.value.startsWith("provider_"))
//         .toList();

//     for (final id in idsToRemove) {
//       _markers.remove(id);
//     }
//   }

//   void clear() {
//     _clearSpMarkers();
//     _selectedProvider = null;
//     _selectedServiceId = null;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     clear();
//     _mapController?.dispose();
//     super.dispose();
//   }
// }