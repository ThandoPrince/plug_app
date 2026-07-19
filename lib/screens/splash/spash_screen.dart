// ignore_for_file: file_names, prefer_const_constructors

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/common/services/storage.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/push_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:permission_handler/permission_handler.dart';

bool isHuaweiDevice = false;

/// Firebase background handler
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(fcm.RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Firebase background notification received");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
  }
}

class SpashScreen extends StatefulWidget {
  const SpashScreen({super.key});

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  bool _hasStarted = false;
  String? _errorMessage;
  

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    if (!_hasStarted) {
      _hasStarted = true;
      _bootstrap();
    }
  }

  void _updateStatus(String message) {
    if (!mounted) return;
    setState(() {
      
    });
  }

  Future<void> _bootstrap() async {
    try {
      await _initializeApp();

      if (!mounted) return;

      final hasOpenedBefore = Storage().getBool('firstOpen') ?? false;
      final auth = AuthSessionController.instance;
      final isLoggedIn =
          auth.clientId;

      if (!mounted) return;

      if (!hasOpenedBefore) {
        Storage().setBool('firstOpen', true);
        if (!mounted) return;
        context.go('/welcome');
      } else if (isLoggedIn == null) {
        context.go('/login');
      } else {
        context.go('/entryPoint');
      }
    } catch (e, st) {
      debugPrint("❌ Splash initialization failed: $e\n$st");

      if (!mounted) return;

      setState(() {
        _errorMessage = "Initialization failed.\nCheck logs for details.";
      });
    }
  }

  Future<void> _initializeApp() async {
    
    await GetStorage.init();

    
    await AuthSessionController.instance.loadSession();

    
    await _detectHuawei();

    if (!isHuaweiDevice) {
      
      await _initializeFirebase();

      fcm.FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      
      await _requestFirebasePermission();
    }

    
    final envLoaded = await _safeLoadEnv();
    if (!envLoaded) {
      throw Exception("Environment loading failed");
    }

    
 

    
    await PushNotificationService.instance.initialize();

    
    await _requestNotificationPermission();

    
  }

  /// Detects if the device relies on Huawei Mobile Services (HMS)
  Future<void> _detectHuawei() async {
    if (!Platform.isAndroid) {
      isHuaweiDevice = false;
      return;
    }

    try {
      final int availability = await HmsApiAvailability().isHMSAvailable();

      if (availability == 0) {
        isHuaweiDevice = true;
        if (kDebugMode) {
          print("HMS detected (Status 0) → Huawei device");
        }
      } else {
        isHuaweiDevice = false;
        if (kDebugMode) {
          print("HMS not available. Status code: $availability");
        }
      }
    } catch (e) {
      isHuaweiDevice = false;
      if (kDebugMode) {
        print("HMS detection failed: $e");
      }
    }
  }

  /// Standard Firebase Initialization
  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      if (kDebugMode) {
        print("Firebase initialized successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firebase init failed: $e");
      }
      rethrow;
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

  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final status = await Permission.notification.request();

      if (kDebugMode) {
        print("Notification permission status: $status");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Notification permission request failed: $e");
      }
    }
  }

  /// HERE SDK Initialization
  

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Widget _buildBackground({required Widget child}) {
    return Container(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: _buildBackground(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 44.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Kolors.kPrimary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        
                      });
                      _bootstrap();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100.h,
              child: Image.asset('assets/icons/plug_icon.png'),
            ),
            
            
          ],
        ),
      ),
    );
  }
}