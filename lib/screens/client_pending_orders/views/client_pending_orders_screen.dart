import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/client_pending_orders/widgets/client_pending_orders_body.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';

class ClientPendingOrdersScreen extends StatefulWidget {
  const ClientPendingOrdersScreen({super.key});

  @override
  State<ClientPendingOrdersScreen> createState() =>
      _ClientPendingOrdersScreenState();
}

class _ClientPendingOrdersScreenState
    extends State<ClientPendingOrdersScreen> {
  bool _showHeader = true;
  String _selectedStatus = "All";

  final List<String> _statuses = [
  "All",
  "Pending",
  "In-Negotiation",
  "Rescheduled",
];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ClientPendingOrdersController>()
          .fetchPendingOrders();
    });
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta! > 0 && _showHeader) {
        setState(() => _showHeader = false);
      } else if (notification.scrollDelta! < 0 && !_showHeader) {
        setState(() => _showHeader = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClientPendingOrdersController>();

    

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: Column(
          children: [
            // HEADER
            SafeArea(
              bottom: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: _showHeader ? 56 : 0,
                child: const Center(
                  child: Text(
                    'My Pending Orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
  height: 48,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: _statuses.length,
    separatorBuilder: (_, __) => const SizedBox(width: 10),
    itemBuilder: (_, index) {
      final status = _statuses[index];
      final selected = _selectedStatus == status;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : Colors.white.withOpacity(.25),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Kolors.kPrimary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                status,
                style: TextStyle(
                  color: selected
                      ? Kolors.kPrimary
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),

            // BODY
            Expanded(
  child: ClientPendingOrdersBody(
    controller: controller,
    selectedStatus: _selectedStatus,
  ),
),
          ],
        ),
      ),
    );
  }
}