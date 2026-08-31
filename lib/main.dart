import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/app_routes.dart';

import 'package:flutter_application_1/const/services/app_initializer.dart';
import 'package:flutter_application_1/global_util/services/api_client.dart';
import 'package:flutter_application_1/screens/splash/providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  String initialRoute = '/login';

  try {
    initialRoute = await AppInitializer.initialize();
  } catch (e) {
    debugPrint('Initialization failed: $e');
    initialRoute = '/login';
  }

  ApiClient.instance.setSessionExpiredHandler(() {
    router.go('/login');
  });

  runApp(
    MultiProvider(
      providers: appProviders,
      child: MyApp(initialRoute: initialRoute),
    ),
  );

  // Remove the native splash after the first frame is rendered.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
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
            return child ?? const SizedBox();
          },
        );
      },
    );
  }
}