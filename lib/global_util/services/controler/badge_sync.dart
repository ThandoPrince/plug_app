import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_controller_cache.dart';

Future<void> syncUnreadBadges(
  ClientPendingOrdersController pendingCtrl,
  NegotiationBadgeStore store,
) async {
  final orders = pendingCtrl.pendingOrders.where((o) =>
      o.orderId != null &&
      (o.status ?? '').toLowerCase().contains('negotiation'));

  await Future.wait(orders.map((o) async {
    try {
      final listCtrl = NegotationByOrderIDController();
      await listCtrl.fetchAllNegotiations(o.orderId!, force: true);

      for (final n in listCtrl.negotiations ?? []) {
        final id = n.negotiationId;
        if (id == null) continue;
        final c = NegotiationControllerCache.instance.controllerFor(id);
        await c.fetchNegotiationById(id, force: true);
        store.syncFromRounds(id, o.orderId, c.negotiation?.rounds ?? []);
      }
      listCtrl.dispose();
    } catch (e) {
      if (kDebugMode) print('badge sync failed for order ${o.orderId}: $e');
    }
  }));
}