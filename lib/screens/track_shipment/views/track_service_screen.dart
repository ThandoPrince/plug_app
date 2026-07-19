import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/track_service_view.dart';


class TrackServiceScreen extends StatefulWidget {
  final Shipment shipment;
  final GoogleShipmentRouteController googleShipmentRouteController;

  const TrackServiceScreen({
    super.key,
    required this.shipment,
    required this.googleShipmentRouteController,
  });

  @override
  State<TrackServiceScreen> createState() => _TrackServiceScreenState();
}

class _TrackServiceScreenState extends State<TrackServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return TrackServiceView(
      shipment: widget.shipment,
      googleShipmentRouteController: widget.googleShipmentRouteController,
    );
  }
}