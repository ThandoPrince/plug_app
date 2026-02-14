import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/schedule/views/scheduled_shipments_screen.dart';
import 'package:provider/provider.dart';

void goToSchedule(BuildContext context) {
  final tabNotifier = context.read<TabIndexNotifier>();
  tabNotifier.setIndex(2); 
  Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);  
}

