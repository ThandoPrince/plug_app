import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';


class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    FlushbarService.dismiss();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FlushbarService.dismiss();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    FlushbarService.dismiss();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
