import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/common/widgets/shimmers/negotiation_card_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
import 'package:flutter_application_1/global_util/services/widgets/app_notification_helper.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_card.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_detail_sheet.dart';
import 'package:provider/provider.dart';

class NegotiationsByOrderidScreen extends StatefulWidget {
  final int orderId;
  const NegotiationsByOrderidScreen({super.key, required this.orderId});

  @override
  State<NegotiationsByOrderidScreen> createState() =>
      _NegotiationsByOrderidScreenState();
}

class _NegotiationsByOrderidScreenState
    extends State<NegotiationsByOrderidScreen> {

      



@override
@override
void initState() {
  super.initState();

  NavigationService.setNegotiationScreen(widget.orderId, true);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    context
        .read<NegotationByOrderIDController>()
        .fetchAllNegotiations(widget.orderId);
  });
}

@override
void dispose() {
  NavigationService.setNegotiationScreen(widget.orderId, false);
  super.dispose();
}

  void _loadNegotiations() {
    final negotiationCtrl =
        Provider.of<NegotationByOrderIDController>(context, listen: false);
    negotiationCtrl.fetchAllNegotiations(widget.orderId);
  }

  Future<void> _refreshNegotiations() async => _loadNegotiations();

  Future<void> _showNegotiationDetail(int negotiationId) async {
     context.read<NegotiationBadgeStore>().clear(negotiationId);
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: NegotiationDetailSheet(
          negotiationId: negotiationId,
          parentContext: context,
        ),
      ),
    ),
  );

  

  if (!mounted || result == null) return;

  if (result["success"] == true) {
  await _refreshNegotiations();
    if (!mounted) return;

    FlushbarService.success(
      context,
      result["message"] ?? "Negotiation removed successfully",
    );

    // Refresh negotiations if needed
  
  } else if (result["success"] == false) {
    FlushbarService.error(
      context,
      result["message"] ?? "Failed to remove negotiation",
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Negotiations", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<NegotationByOrderIDController>(
            builder: (context, ctrl, _) {
              if (ctrl.isLoading) {
  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(vertical: 12),
    itemCount: 5,
    itemBuilder: (_, index) {
      return const NegotiationCardSkeleton();
    },
  );
}

              if (ctrl.errorMessage != null && ctrl.errorMessage!.isNotEmpty) {
                return Center(
                  child: Text(
                    ctrl.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                );
              }

              final negotiations = ctrl.negotiations;
              if (negotiations == null || negotiations.isEmpty) {
                return ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: [
    const SizedBox(height: 120),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 100,
          color: Colors.white.withOpacity(0.6),
        ),
        const SizedBox(height: 20),
        const Text(
          "No Negotiations Found",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Kolors.kWhite,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "There are currently no negotiation requests to display.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Kolors.kWhite.withOpacity(0.8),
          ),
        ),
      ],
    ),
  ],

                );
              }

              return RefreshIndicator(
                onRefresh: _refreshNegotiations,
                color: Kolors.kPrimary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: negotiations.length,
                  itemBuilder: (context, index) {
                    final negotiation = negotiations[index];
                    return GestureDetector(
                      onTap: () {
                        if (negotiation.negotiationId != null) {
                          _showNegotiationDetail(negotiation.negotiationId!);
                        } else {
                         Flushbar(
                            title: "Error",
                            message: "Negotiation ID is missing.",
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 3),
                          ).show(context);
                        }
                      },
                      child: NegotiationCard(negotiation: negotiation),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
