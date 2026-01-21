import 'package:flutter/material.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_route_controller.dart';

class MapSection extends StatefulWidget {
  final ShipmentRouteController routeController;
  const MapSection({super.key, required this.routeController});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  late HereMapController _mapController;

  @override
  void dispose() {
    widget.routeController.clear();
    super.dispose();
  }

  void onMapCreated(HereMapController mapController) {
    _mapController = mapController;

    mapController.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (error) {
        if (error != null) {
          debugPrint("❌ Map scene load error: $error");
          return;
        }

        _registerGestureListeners(mapController);
        widget.routeController.loadShipmentRoutesAndFocus(_mapController);
      },
    );
  }

  void _registerGestureListeners(HereMapController controller) {
    final gestures = controller.gestures;

    gestures.panListener = PanListener((state, _, __, ___) {
      if (state == GestureState.begin) widget.routeController.disableFollow();
    });

    gestures.twoFingerPanListener = TwoFingerPanListener((state, _, __, ___) {
      if (state == GestureState.begin) widget.routeController.disableFollow();
    });

    gestures.tapListener = TapListener((_) {
      widget.routeController.disableFollow();
    });

    gestures.longPressListener = LongPressListener((state, _) {
      if (state == GestureState.begin) widget.routeController.disableFollow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HereMap(onMapCreated: onMapCreated),

        // 🔹 Recenter button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
  onPressed: () {
    widget.routeController.recenterOnProvider();
  },
  child: Icon(Icons.my_location),
),
        ),
      ],
    );
  }
}
