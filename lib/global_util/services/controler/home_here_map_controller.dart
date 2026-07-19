// import 'dart:ui' as ui;
// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
// import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
// import 'package:here_sdk/core.dart';
// import 'package:here_sdk/mapview.dart';
// import 'package:here_sdk/gestures.dart';
// import 'package:provider/provider.dart';

// import '../models/sp_live_location_model.dart';
// import '../models/client_models/address_client_model.dart';
// import '../controler/sp_add_by_id_ctrl.dart';
// import '../controler/def_add_controller.dart';

// class HereMapMarkerController extends ChangeNotifier {
//   // ----------------------------
//   // Selected Service & Provider
//   // ----------------------------
//   int? _selectedServiceId;
//   int? get selectedServiceId => _selectedServiceId;
  

//   SPLiveLocationModel? _selectedProvider;
//   SPLiveLocationModel? get selectedProvider => _selectedProvider;

//   // ----------------------------
//   // Map & Marker Storage
//   // ----------------------------
//   static final GeoCoordinates fallbackCenter = GeoCoordinates(-26.2041, 28.0473);
//   HereMapController? _mapController;

//   final List<MapMarker> _markers = [];
//   List<MapMarker> get markers => List.unmodifiable(_markers);
  

//   final List<SPLiveLocationModel> _visibleProviders = [];
//   List<SPLiveLocationModel> get visibleProviders => List.unmodifiable(_visibleProviders);

//   MapImage? _defaultIcon;
//   MapImage? _spIcon;

//   // Keep reference to default marker
//   MapMarker? _defaultMarker;

//   // ----------------------------
//   // Controllers
//   // ----------------------------
//   final SpAddressControllerByID spAddrCtrl;
//   final DefAddController defAddCtrl;

//   HereMapMarkerController({required this.spAddrCtrl, required this.defAddCtrl});

//   // ----------------------------
//   // Map Initialization
//   // ----------------------------

//  void onMapCreated(HereMapController controller, BuildContext context) async {
//   final addressCtrl = context.read<AddressClientCtrl>();
    
//   _mapController = controller;

//   controller.mapScene.loadSceneForMapScheme(
//     MapScheme.normalDay,
//     (error) async {
//       if (error != null) {
//         debugPrint("❌ Map load error: $error");
//         return;
//       }

//       _configureGestures(controller);
//       _focusOnFallback();
      

//       await _ensureMarkerImagesLoaded();
//       await showDefaultAddress();
//       await restoreMarkers();

//       // ✅ Get email from AuthSession
//       final session = context.read<AuthSessionController>();
   
//     },
//   );
// }

// void focusOnUserOrDefault() {
//   if (_mapController == null) return;

//   final coords = _defaultMarker?.coordinates ?? fallbackCenter;

//   _mapController!.camera.lookAtPointWithGeoOrientationAndMeasure(
//     coords,
//     GeoOrientationUpdate(0, 0),
//     MapMeasure(
//       MapMeasureKind.distanceInMeters,
//       900, // 🔥 change from 1200 → forces visual update
//     ),
//   );
// }
//   void removeSpMarkers() {
//   for (final m in List<MapMarker>.from(_markers)) {
//     if (m.metadata?.getString("provider_id") != null) {
//       _mapController?.mapScene.removeMapMarker(m);
//       _markers.remove(m);
//     }
//     _selectedServiceId = null; // also unselect service
//   _selectedProvider = null;  // clear selected provider
//   }
//   notifyListeners();
// }

//   void _configureGestures(HereMapController controller) {
//     controller.gestures.tapListener = TapListener((_) {
//       // Marker taps handled via onMarkerTap()
//     });
//   }

//   // ----------------------------
//   // Marker Images
//   // ----------------------------
//   Future<MapImage> _loadMarkerImage(String assetPath, int size) async {
//     final data = await rootBundle.load(assetPath);
//     final codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetWidth: size,
//     );
//     final frame = await codec.getNextFrame();
//     final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);

//     return MapImage.withPixelDataAndImageFormat(
//       bytes!.buffer.asUint8List(),
//       ImageFormat.png,
//     );
//   }

//   Future<void> _ensureMarkerImagesLoaded() async {
//     _defaultIcon ??= await _loadMarkerImage("assets/icons/default_marker.png", 96);
//     _spIcon ??= await _loadMarkerImage("assets/icons/sp_marker.png", 100);
//   }

//   // ----------------------------
//   // Service Selection
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
//   // Default Address
//   // ----------------------------
//   Future<void> showDefaultAddress() async {
//     if (_mapController == null) return;
    

//     await defAddCtrl.fetchAddresses();

//     final defaultAddr = defAddCtrl.addresses.firstWhere(
//       (a) => a.isDefault == true,
//       orElse: () => defAddCtrl.addresses.isNotEmpty ? defAddCtrl.addresses.first : null as AddressClientModel,
//     );

//     final coords = GeoCoordinates(
//       defaultAddr.address.latitude ?? fallbackCenter.latitude,
//       defaultAddr.address.longitude ?? fallbackCenter.longitude,
//     );

//     // Remove old default marker from map
//     if (_defaultMarker != null) {
//       _mapController?.mapScene.removeMapMarker(_defaultMarker!);
//       _markers.remove(_defaultMarker);
//     }

//     // Add new default marker
//     final defaultMeta = Metadata()..setString("default_address", "true");
//     _defaultMarker = MapMarker(coords, _defaultIcon!)
//       ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1)
//       ..metadata = defaultMeta;

//     _markers.add(_defaultMarker!);
//     _mapController?.mapScene.addMapMarker(_defaultMarker!);

//     // Focus camera
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _focusCamera(coords);
//     });

//     notifyListeners();
//     }

//   // ----------------------------
//   // Service Provider Markers
//   // ----------------------------
//   Future<void> showServiceProviders(int serviceId) async {
//   if (_mapController == null) return;

//   await _ensureMarkerImagesLoaded();
//   _clearSpMarkers();
//   _visibleProviders.clear();
//   _selectedServiceId = serviceId;

//   await spAddrCtrl.fetchAddressesByService(serviceId);

//   debugPrint("Providers returned: ${spAddrCtrl.addresses.length}");

// for (final sp in spAddrCtrl.addresses) {
//   debugPrint(
//     "Provider ${sp.providerId} "
//     "Lat=${sp.latitude} "
//     "Lng=${sp.longitude}",
//   );
// }

//   for (final sp in spAddrCtrl.addresses) {
//     if (sp.latitude == null || sp.longitude == null) continue;

//     final coords = GeoCoordinates(sp.latitude!, sp.longitude!);
//     final spMeta = Metadata()..setString("provider_id", sp.providerId.toString());

//     final marker = MapMarker(coords, _spIcon!)
//       ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1)
//       ..metadata = spMeta;

//     _markers.add(marker);
//     _mapController?.mapScene.addMapMarker(marker);
//     _visibleProviders.add(sp);
//   }

//   // Zoom only to SP markers (exclude default address)
//   _fitMarkersToSPBounds();

//   notifyListeners();
// }

// void _fitMarkersToSPBounds() {
//   if (_visibleProviders.isEmpty || _mapController == null) return;

//   double minLat = _visibleProviders.first.latitude!;
//   double maxLat = minLat;
//   double minLng = _visibleProviders.first.longitude!;
//   double maxLng = minLng;

//   for (final sp in _visibleProviders) {
//     minLat = min(minLat, sp.latitude!);
//     maxLat = max(maxLat, sp.latitude!);
//     minLng = min(minLng, sp.longitude!);
//     maxLng = max(maxLng, sp.longitude!);
//   }

//   // Add padding (e.g., 0.002 = ~200m, tweak as needed)
//   const double padding = 0.002;
//   minLat -= padding;
//   maxLat += padding;
//   minLng -= padding;
//   maxLng += padding;

//   final geoBox = GeoBox(GeoCoordinates(minLat, minLng), GeoCoordinates(maxLat, maxLng));

//   _mapController?.camera.principalPoint = Point2D(0.5, 0.35);
//   _mapController?.camera.lookAtAreaWithGeoOrientation(geoBox, GeoOrientationUpdate(0, 0));
// }

// Future<void> restoreMarkers() async {
//   if (_mapController == null) return;

//   // Re-add default marker
//   if (_defaultMarker != null && !_markers.contains(_defaultMarker)) {
//     _markers.add(_defaultMarker!);
//     _mapController!.mapScene.addMapMarker(_defaultMarker!);
//   }

//   // Re-add SP markers
//   for (final sp in _visibleProviders) {
//     final exists = _markers.any((m) =>
//         m.metadata?.getString("provider_id") == sp.providerId.toString());
//     if (!exists) {
//       final coords = GeoCoordinates(sp.latitude!, sp.longitude!);
//       final spMeta = Metadata()..setString("provider_id", sp.providerId.toString());
//       final marker = MapMarker(coords, _spIcon!)
//         ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1)
//         ..metadata = spMeta;

//       _markers.add(marker);
//       _mapController!.mapScene.addMapMarker(marker);
//     }
//   }
// }



//   void onMarkerTap(MapMarker marker) {
//     final providerIdStr = marker.metadata?.getString("provider_id");
//     if (providerIdStr == null) return;

//     final providerId = int.tryParse(providerIdStr);
//     if (providerId == null) return;

//     _selectedProvider = _visibleProviders.firstWhere(
//       (p) => p.providerId == providerId,
//       orElse: () => _selectedProvider!,
//     );

//     notifyListeners();
//   }

//   // ----------------------------
//   // Camera Helpers
//   // ----------------------------
//   void _focusCamera(GeoCoordinates coords) {
//     _mapController?.camera.lookAtPointWithGeoOrientationAndMeasure(
//       coords,
//       GeoOrientationUpdate(0, 0),
//       MapMeasure(MapMeasureKind.distanceInMeters, 1500),
//     );
//   }

//   void _focusOnFallback() {
//     _mapController?.camera.lookAtPointWithGeoOrientationAndMeasure(
//       fallbackCenter,
//       GeoOrientationUpdate(0, 0),
//       MapMeasure(MapMeasureKind.distanceInMeters, 3000),
//     );
//   }

//   void _fitMarkersToBounds() {
//     if (_markers.isEmpty || _mapController == null) return;

//     double minLat = _markers.first.coordinates.latitude;
//     double maxLat = minLat;
//     double minLng = _markers.first.coordinates.longitude;
//     double maxLng = minLng;

//     for (final m in _markers) {
//       final c = m.coordinates;
//       minLat = min(minLat, c.latitude);
//       maxLat = max(maxLat, c.latitude);
//       minLng = min(minLng, c.longitude);
//       maxLng = max(maxLng, c.longitude);
//     }

//     final geoBox = GeoBox(GeoCoordinates(minLat, minLng), GeoCoordinates(maxLat, maxLng));

//     _mapController?.camera.principalPoint = Point2D(0.5, 0.35);
//     _mapController?.camera.lookAtAreaWithGeoOrientation(geoBox, GeoOrientationUpdate(0, 0));
//   }

//   // ----------------------------
//   // Clear / Dispose
//   // ----------------------------
//   void _clearSpMarkers() {
//     if (_mapController == null) return;

//     for (final m in List<MapMarker>.from(_markers)) {
//       final isSpMarker = m.metadata?.getString("provider_id") != null;
//       if (isSpMarker) {
//         _mapController?.mapScene.removeMapMarker(m);
//         _markers.remove(m);
//       }
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
//     super.dispose();
//   }
// }
