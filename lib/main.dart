import 'dart:io';
import 'dart:async';

// Prefixing to solve the RemoteMessage collision
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_application_1/global_util/services/widgets/push_notification_service.dart';

import 'package:flutter_application_1/screens/splash/providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';

import 'common/utils/app_routes.dart';
import 'global_util/services/controler/auth_session_controller.dart';

bool isHuaweiDevice = false;

/// --------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(fcm.RemoteMessage message) async {
  // Required for background isolate
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Firebase background notification received");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage & Sessions
  await GetStorage.init();
  await AuthSessionController.instance.loadSession();

  // 1. Detect Hardware Environment
  await _detectHuawei();

  // 2. Initialize Push Infrastructure based on hardware
  if (!isHuaweiDevice) {
    await _initializeFirebase();

    // Must be registered before runApp
    fcm.FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // FCM permission request
    await _requestFirebasePermission();
  }

  // 3. Load Environment Variables
  bool envLoaded = await _safeLoadEnv();

  // 4. Initialize Mapping SDK
  if (envLoaded) {
    await _initializeHERESDK();
  }

  // 5. Initialize Push Notification Logic
  await PushNotificationService.instance.initialize();

  // Optional Android 13+ OS permission request
  await requestNotificationPermission();

  runApp(
    MultiProvider(
      providers: appProviders,
      child: const MyApp(),
    ),
  );
}

/// Detects if the device relies on Huawei Mobile Services (HMS)
Future<void> _detectHuawei() async {
  if (!Platform.isAndroid) return;

  try {
    final int availability = await HmsApiAvailability().isHMSAvailable();

    if (availability == 0) {
      isHuaweiDevice = true;
      if (kDebugMode) {
        print("HMS detected (Status 0) → Huawei device");
      }
    } else {
      if (kDebugMode) {
        print("HMS not available. Status code: $availability");
      }
      isHuaweiDevice = false;
    }
  } catch (e) {
    if (kDebugMode) print("HMS detection failed: $e");
    isHuaweiDevice = false;
  }
}

/// Standard Firebase Initialization
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    if (kDebugMode) print("Firebase initialized successfully");
  } catch (e) {
    if (kDebugMode) print("Firebase init failed: $e");
  }
}

/// Request permission specifically for Firebase Messaging
Future<void> _requestFirebasePermission() async {
  try {
    final settings = await fcm.FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print("FCM permission status: ${settings.authorizationStatus}");
    }
  } catch (e) {
    if (kDebugMode) {
      print("FCM permission request failed: $e");
    }
  }
}

/// Safe Environment Loading
Future<bool> _safeLoadEnv() async {
  final envFile = kReleaseMode ? ".env.production" : ".env.development";
  try {
    await dotenv.load(fileName: envFile);
    debugPrint("Environment loaded from $envFile");
    return true;
  } catch (e) {
    debugPrint("Could not load $envFile: $e");
    return false;
  }
}

Future<void> requestNotificationPermission() async {
  if (!Platform.isAndroid) return;

  final status = await Permission.notification.request();

  if (kDebugMode) {
    print("Notification permission status: $status");
  }
}

/// HERE SDK Initialization
Future<void> _initializeHERESDK() async {
  final accessKeyId = dotenv.env['HEREACCESSKEYID'] ?? '';
  final accessKeySecret = dotenv.env['HEREKEYSECRET'] ?? '';

  SdkContext.init(IsolateOrigin.main);
  final authMode =
      AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
  final options = SDKOptions.withAuthenticationMode(authMode);

  try {
    await SDKNativeEngine.makeSharedInstance(options);
    debugPrint("HERE SDK initialized");
  } on InstantiationException {
    debugPrint("HERE SDK failed to initialize");
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
          theme: ThemeData(
            useMaterial3: false,
            primaryColor: Kolors.kPrimary,
          ),
          routerConfig: router,
        );
      },
    );
  }
}