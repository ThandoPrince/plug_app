import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNegotiations();
    });
  }

  void _loadNegotiations() {
    final negotiationCtrl =
        Provider.of<NegotationByOrderIDController>(context, listen: false);
    negotiationCtrl.fetchAllNegotiations(widget.orderId);
  }

  Future<void> _refreshNegotiations() async => _loadNegotiations();

  void _showNegotiationDetail(int negotiationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: NegotiationDetailSheet(
          negotiationId: negotiationId,
          parentContext: context, 
          
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Negotiations", style: TextStyle(fontWeight: FontWeight.bold)),
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
                return const Center(
                  child: CircularProgressIndicator(color: Kolors.kWhite),
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
                return const Center(
                  child: Text(
                    "No negotiations found.",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500, 
                      color: Kolors.kWhite
                    ),
                  ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Negotiation ID not found"),
                              backgroundColor: Colors.red,
                            ),
                          );
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
