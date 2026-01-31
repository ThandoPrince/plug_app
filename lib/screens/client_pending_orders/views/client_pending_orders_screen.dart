import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/client_pending_orders/widgets/client_pending_orders_body.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';

class ClientPendingOrdersScreen extends StatefulWidget {
  final String clientEmail;

  const ClientPendingOrdersScreen({
    super.key,
    required this.clientEmail,
  });

  @override
  State<ClientPendingOrdersScreen> createState() =>
      _ClientPendingOrdersScreenState();
}

class _ClientPendingOrdersScreenState
    extends State<ClientPendingOrdersScreen> {
  late final ClientPendingOrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClientPendingOrdersController();
    _controller.fetchPendingOrders(widget.clientEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Pending Orders'),
          backgroundColor: Kolors.kPrimary,
          elevation: 2,
        ),
        body: ClientPendingOrdersBody(
          clientEmail: widget.clientEmail,
        ),
      ),
    );
  }
}
