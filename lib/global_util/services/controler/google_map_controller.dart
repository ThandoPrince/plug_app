import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import '../models/sp_live_location_model.dart';
import '../models/client_models/address_client_model.dart';
import '../controler/sp_add_by_id_ctrl.dart';
import '../controler/def_add_controller.dart';

class GoogleMapMarkerController extends ChangeNotifier {
  // ----------------------------
  // Selected Service & Provider
  // ----------------------------
  int? _selectedServiceId;
  int? get selectedServiceId => _selectedServiceId;
  bool _clientAnchorLocked = true;
bool get clientAnchorLocked => _clientAnchorLocked;
bool get _isHighDensityCluster => _visibleProviders.length > 10;
bool _defaultLoaded = false;


  SPLiveLocationModel? _selectedProvider;
  SPLiveLocationModel? get selectedProvider => _selectedProvider;

  // ----------------------------
  // Map & Marker Storage
  // ----------------------------
  static const LatLng fallbackCenter = LatLng(-26.2041, 28.0473);
  GoogleMapController? _mapController;

  final Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final List<SPLiveLocationModel> _visibleProviders = [];
  List<SPLiveLocationModel> get visibleProviders =>
      List.unmodifiable(_visibleProviders);

  BitmapDescriptor? _defaultIcon;
  BitmapDescriptor? _spIcon;

  // Keep reference parameters to default marker state
  LatLng? _defaultLatLng;

  // ----------------------------
  // Controllers
  // ----------------------------
  final SpAddressControllerByID spAddrCtrl;
  final DefAddController defAddCtrl;

  GoogleMapMarkerController(
      {required this.spAddrCtrl, required this.defAddCtrl});

  // ----------------------------
  // Map Initialization
  // ----------------------------

Future<void> preloadMarkerImages() => _ensureMarkerImagesLoaded();
  


void onMapCreated(GoogleMapController controller, BuildContext context) async {
  _mapController = controller;
  _mapController!.setMapStyle(null);

  // Icons are already loaded (see initState preload) — this is now a no-op
  // thanks to the ??= guards, but keep it for safety on cold paths.
  await _ensureMarkerImagesLoaded();

  // Give the native platform view a beat to fully attach before the
  // first addMarker call — avoids the custom icon silently falling back
  // to BitmapDescriptor.defaultMarker on first render.
  await Future.delayed(const Duration(milliseconds: 250));

  await showDefaultAddress();
  await restoreMarkers();

  if (context.mounted) {
    final session = context.read<AuthSessionController>();
  }
}

  void focusOnUserOrDefault() {
    if (_mapController == null) return;

    final targetCoords = _defaultLatLng ?? fallbackCenter;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
          targetCoords, 16.0), // ~900m spatial zoom match
    );
  }

  void unlockClientAnchor() {
  _clientAnchorLocked = false;
  notifyListeners();
}

void lockClientAnchor() {
  _clientAnchorLocked = true;

  if (_defaultLatLng != null) {
    _focusCamera(_defaultLatLng!);
  }

  notifyListeners();
}

  void removeSpMarkers() {
    _markers.removeWhere((id, marker) => id.value.startsWith("provider_"));
    _selectedServiceId = null;
    _selectedProvider = null;
    notifyListeners();
  }

  // ----------------------------
  // Marker Configuration & Loading
  // ----------------------------
  Future<BitmapDescriptor> _loadMarkerImage(String assetPath, int size) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ByteData? bytes =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _ensureMarkerImagesLoaded() async {
    _defaultIcon ??=
        await _loadMarkerImage("assets/icons/default_marker.png", 96);
    _spIcon ??= await _loadMarkerImage("assets/icons/sp_marker.png", 100);
  }

  // ----------------------------
  // Service Selection
  // ----------------------------
  void selectService(int serviceId) {
    _selectedServiceId = serviceId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedServiceId = null;
    _selectedProvider = null;
    _clearSpMarkers();
    notifyListeners();
  }

  // ----------------------------
  // Default Address Handler
  // ----------------------------
Future<void> showDefaultAddress({bool force = false}) async {
  if (_defaultLoaded && !force) {
    // Default address already known from an earlier prefetch (e.g. before
    // the map widget existed) — skip refetching, but still focus the
    // camera now that a controller may finally be attached.
    if (_defaultLatLng != null) {
      _focusCamera(_defaultLatLng!);
    }
    notifyListeners();
    return;
  }

  await defAddCtrl.fetchAddresses();

  final defaultAddr = defAddCtrl.addresses.firstWhere(
    (a) => a.isDefault == true,
    orElse: () => defAddCtrl.addresses.isNotEmpty
        ? defAddCtrl.addresses.first
        : null as AddressClientModel,
  );

  final coords = LatLng(
    defaultAddr.address.latitude ?? fallbackCenter.latitude,
    defaultAddr.address.longitude ?? fallbackCenter.longitude,
  );

  _defaultLatLng = coords;
  const MarkerId defaultMarkerId = MarkerId("default_address");

  final Marker defaultMarker = Marker(
    markerId: defaultMarkerId,
    position: coords,
    icon: _defaultIcon ?? BitmapDescriptor.defaultMarker,
    anchor: const Offset(0.5, 1.0),
  );

  _markers[defaultMarkerId] = defaultMarker;
  _defaultLoaded = true;

  Future.delayed(const Duration(milliseconds: 300), () {
    _focusCamera(coords);
  });

  notifyListeners();
}
  // ----------------------------
  // Service Provider Markers Implementation
  // ----------------------------
  Future<void> showServiceProviders(int serviceId) async {
    if (_mapController == null) return;

    await _ensureMarkerImagesLoaded();
    _clearSpMarkers();
    _visibleProviders.clear();
    _selectedServiceId = serviceId;

    await spAddrCtrl.fetchAddressesByService(serviceId);

    for (final sp in spAddrCtrl.addresses) {
      if (sp.latitude == null || sp.longitude == null || sp.providerId == null)
        continue;

      final coords = LatLng(sp.latitude!, sp.longitude!);
      final markerId = MarkerId("provider_${sp.providerId!}");

      final marker = Marker(
        markerId: markerId,
        position: coords,
        icon: _spIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 1.0),
        onTap: () => _onMarkerTapped(sp.providerId!),
      );

      _markers[markerId] = marker;
      _visibleProviders.add(sp);
    }

    _fitMarkersToSPBounds();
    notifyListeners();
  }

  void _fitMarkersToSPBounds() {
  if (_mapController == null) return;

  final List<LatLng> points = [];

  if (_defaultLatLng != null) {
    points.add(_defaultLatLng!);
  }

  for (final sp in _visibleProviders) {
    if (sp.latitude != null && sp.longitude != null) {
      points.add(LatLng(sp.latitude!, sp.longitude!));
    }
  }

  if (points.isEmpty) return;

  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (final p in points) {
    minLat = min(minLat, p.latitude);
    maxLat = max(maxLat, p.latitude);
    minLng = min(minLng, p.longitude);
    maxLng = max(maxLng, p.longitude);
  }

  final bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );

  final bool highDensity = _visibleProviders.length > 10;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _applyBounds(bounds, highDensity, minLat, maxLat, minLng, maxLng);
  });
}

void _applyBounds(
  LatLngBounds bounds,
  bool highDensity,
  double minLat,
  double maxLat,
  double minLng,
  double maxLng,
) {
  if (_mapController == null) return;

  final center = LatLng(
    (minLat + maxLat) / 2,
    (minLng + maxLng) / 2,
  );

  final double latDiff = (maxLat - minLat).abs();
  final double lngDiff = (maxLng - minLng).abs();
  final double maxDiff = max(latDiff, lngDiff);

  // -------------------------
  // CASE 1: HIGH DENSITY
  // -------------------------
  if (highDensity) {
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(center, 11.5),
    );
    return;
  }

  // -------------------------
  // CASE 2: VERY CLOSE
  // -------------------------
  if (maxDiff < 0.005) {
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(center, 16.5),
    );
    return;
  }

  // -------------------------
  // CASE 3: NORMAL BOUNDS (IMPORTANT FIX)
  // -------------------------

  // 👇 THIS IS THE KEY FIX
  Future.delayed(const Duration(milliseconds: 80), () {
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 140),
    );
  });
}

Future<void> _smoothMove(CameraUpdate target) async {
  if (_mapController == null) return;

  // Step 1: slight zoom out (preparation phase)
  await _mapController!.animateCamera(
    CameraUpdate.zoomBy(-0.8),
  );

  await Future.delayed(const Duration(milliseconds: 120));

  // Step 2: move to target
  await _mapController!.animateCamera(target);

  await Future.delayed(const Duration(milliseconds: 80));

  // Step 3: settle zoom
  await _mapController!.animateCamera(
    CameraUpdate.zoomBy(0.4),
  );
}

  Future<void> restoreMarkers() async {
    if (_mapController == null) return;

    // Verify fallback status for missing configuration items
    if (_defaultLatLng != null) {
      final defaultId = const MarkerId("default_address");
      if (!_markers.containsKey(defaultId)) {
        _markers[defaultId] = Marker(
          markerId: defaultId,
          position: _defaultLatLng!,
          icon: _defaultIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 1.0),
        );
      }
    }

    for (final sp in _visibleProviders) {
      final markerId = MarkerId("provider_${sp.providerId}");
      if (!_markers.containsKey(markerId)) {
        _markers[markerId] = Marker(
          markerId: markerId,
          position: LatLng(sp.latitude!, sp.longitude!),
          icon: _spIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 1.0),
          onTap: () => _onMarkerTapped(sp.providerId!),
        );
      }
    }
    notifyListeners();
  }

  void _onMarkerTapped(int providerId) {
    _selectedProvider = _visibleProviders.firstWhere(
      (p) => p.providerId == providerId,
      orElse: () => _selectedProvider!,
    );
    notifyListeners();
  }

  // ----------------------------
  // Camera Helper Operations
  // ----------------------------
  void _focusCamera(LatLng coords) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
          coords, 14.5), // Maps perfectly to 1500m area distance
    );
  }

  void _clearSpMarkers() {
    _markers.removeWhere((id, marker) => id.value.startsWith("provider_"));
  }

  void clear() {
    _clearSpMarkers();
    _selectedProvider = null;
    _selectedServiceId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
