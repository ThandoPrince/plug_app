import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/google_shipment_route_controller.dart';
import 'package:flutter_application_1/screens/track_shipment/widgets/track_service_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_route_controller.dart';



class TrackServiceScreen extends StatelessWidget {
  final Shipment shipment;

  const TrackServiceScreen({
    super.key,
    required this.shipment,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoogleShipmentRouteController(
        shipment: shipment,
        shipmentController: context.read<ShipmentController>(),
      ),
      child: TrackServiceView(
        shipment: shipment,
      ),
    );
  }
}
