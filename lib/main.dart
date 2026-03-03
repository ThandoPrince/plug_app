import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/splash/providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:provider/provider.dart';

import 'common/utils/app_routes.dart';

import 'global_util/services/controler/auth_session_controller.dart';
import 'package:here_sdk/core.engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage and session
  await GetStorage.init();
  await AuthSessionController.instance.loadSession();

  runApp(
    MultiProvider(
      providers: appProviders, // <-- use the separated providers
      child: const MyApp(),
    ),
  );

  _initializeHERESDK();
}

Future<void> _initializeHERESDK() async {
  SdkContext.init(IsolateOrigin.main);
  const accessKeyId = "A4BPfmQeylObiKyCy4bpVw";
  const accessKeySecret =
      "fJ-0ruCb_mS29BQk46Hi28mp6toudzEIViGwUgiihVmLVgzAvnGB9P6KFDKgFDdSpB9_RHv4mbPW4d4DMudlRQ";

  final authenticationMode =
      AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
  final sdkOptions = SDKOptions.withAuthenticationMode(authenticationMode);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
    debugPrint("✅ HERE SDK initialized");
  } on InstantiationException {
    debugPrint("⚠️ Failed to initialize HERE SDK");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Plug App',
          theme: ThemeData(useMaterial3: false),
          routerConfig: router,
        );
      },
    );
  }
}