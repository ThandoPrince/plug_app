import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_accepted_view.dart';
import 'package:provider/provider.dart';

class NegotiationAcceptedScreen extends StatelessWidget {
  final int orderId;

  const NegotiationAcceptedScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Negotiation Accepted",
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          child: SafeArea(
            bottom: false,
            child: NegotiationAcceptedView(
             onGoToSchedule: () {

  final tabNotifier = context.read<TabIndexNotifier>();
  Navigator.of(context).popUntil((route) => route.isFirst);

  tabNotifier.setIndex(2);
},
            ),
          ),
        ),
      ),
    );
  }
}