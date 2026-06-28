import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/app_routes.dart';
import 'package:flutter_application_1/common/widgets/network_sensitivy_container.dart';
import 'package:flutter_application_1/const/services/app_initializer.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/screens/splash/providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String initialRoute = '/login';

  try {
    initialRoute = await AppInitializer.initialize();
  } catch (e) {
    debugPrint('Initialization failed: $e');
    initialRoute = '/login';
  }

//   ApiClient.instance.setSessionExpiredHandler(() {
//   navigatorKey.currentState?.pushNamedAndRemoveUntil(
//     '/login',
//     (route) => false,
//   );
// });

ApiClient.instance.setSessionExpiredHandler(() {
  router.go('/login');
});

  runApp(
    MultiProvider(
      providers: appProviders,
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: createRouter(initialRoute),
          builder: (context, child) {
            return SensitiveContainer(
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}