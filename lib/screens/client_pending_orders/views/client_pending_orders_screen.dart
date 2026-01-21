import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/client_pending_orders/widgets/client_pending_orders_body.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';

class ClientPendingOrdersScreen extends StatefulWidget {
  final String clientEmail;

  const ClientPendingOrdersScreen({super.key, required this.clientEmail});

  @override
  State<ClientPendingOrdersScreen> createState() =>
      _ClientPendingOrdersScreenState();
}

class _ClientPendingOrdersScreenState extends State<ClientPendingOrdersScreen> {
  late ClientPendingOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pending Orders'),
        backgroundColor: Kolors.kPrimary,
        elevation: 2,
      ),
      body: ChangeNotifierProvider(
        create: (context) {
          controller = ClientPendingOrdersController();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.fetchPendingOrders(widget.clientEmail);
          });
          return controller;
        },
        child: ClientPendingOrdersBody(
          clientEmail: 't.p.tshabalala98@gmail.com',
        ),
      ),
    );
  }
}
