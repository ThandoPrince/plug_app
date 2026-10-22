import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/app_notification_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:flutter_application_1/common/services/storage.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/push_notification_service.dart';

/// MUST stay top-level
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(fcm.RemoteMessage message) async {
  await Firebase.initializeApp();
}

class AppInitializer {
  AppInitializer._();

  static bool _isHuawei = false;

  static Future<String> initialize() async {
    await GetStorage.init();

    await AuthSessionController.instance.loadSession();
    await NegotiationBadgeStore.global.load(); 

    // 1. detect platform first
    await _detectHuawei();

    // 2. env must load early (needed for services)
    final envLoaded = await _safeLoadEnv();
    if (!envLoaded) throw Exception("Environment loading failed");

  

    // 4. EVENT SYSTEM (IMPORTANT — MUST BE BEFORE PUSH)
    _registerEventSystem();

    // 5. PUSH NOTIFICATIONS
    await PushNotificationService.instance.initialize();

    // 6. PERMISSIONS
    await _requestNotificationPermission();

    if (!_isHuawei) {
      await Firebase.initializeApp();

      fcm.FirebaseMessaging.onBackgroundMessage(
        firebaseBackgroundHandler,
      );

      await _requestFirebasePermission();
    }

    return _resolveRoute();
  }

  // ---------------- ROUTING ----------------


static String _resolveRoute() {
  final hasOpenedBefore =
      Storage().getBool('firstOpen') ?? false;

  final auth = AuthSessionController.instance;
  final isLoggedIn = auth.isLoggedIn;

  if (!hasOpenedBefore) {
    return '/welcome';
  }

  if (!isLoggedIn) {
    return '/login';
  }

  return '/entryPoint';
}


  static void _registerEventSystem() {
  AppEventRouter.register((event) {
    switch (event.type) {
      case AppEventType.negotiationRoundCreated:
        _handleNegotiationRound(event);
        break;
    }
  });
}

static void _handleNegotiationRound(AppEvent event) {

  
  final negotiationId = event.negotiationId;
  final roundId = event.roundId;
  if (negotiationId == null || roundId == null) return; // can't dedupe without it

  NegotiationBadgeStore.global.registerRound(
    negotiationId: negotiationId,
    roundId: roundId,
    senderType: event.senderType,
    orderId: event.orderId == 0 ? null : event.orderId,
  );
}

  // ---------------- INIT BLOCKS ----------------

  static Future<void> _detectHuawei() async {
    if (!Platform.isAndroid) {
      _isHuawei = false;
      return;
    }

    try {
      final status = await HmsApiAvailability().isHMSAvailable();
      _isHuawei = status == 0;

      if (kDebugMode) {
        print("Huawei device: $_isHuawei");
      }
    } catch (_) {
      _isHuawei = false;
    }
  }

  static Future<void> _requestFirebasePermission() async {
    try {
      await fcm.FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}
  }

  static Future<bool> _safeLoadEnv() async {
    final envFile =
        kReleaseMode ? ".env.production" : ".env.development";

    try {
      await dotenv.load(fileName: envFile);
      return true;
    } catch (e) {
      debugPrint("ENV load failed: $e");
      return false;
    }
  }

  

  static Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;

    await Permission.notification.request();
  }
}