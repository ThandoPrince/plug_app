import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:huawei_push/huawei_push.dart' as hms;

import '../../../../../main.dart';

class PushNotificationService {
  static final PushNotificationService instance =
      PushNotificationService._internal();

  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<hms.RemoteMessage>? _huaweiMessageSub;
  StreamSubscription<dynamic>? _huaweiOpenSub;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'plug_high_importance',
    'Plug Notifications',
    description: 'Notifications for bookings, negotiations and updates',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await _initializeLocalNotifications();

    if (isHuaweiDevice) {
      await _initializeHuawei();
    } else {
      await _initializeFirebase();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print("Local notification tapped: ${response.payload}");
        }

        if (response.payload == null || response.payload!.isEmpty) return;

        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          _handleNotification(data);
        } catch (e) {
          if (kDebugMode) {
            print("Failed to decode local notification payload: $e");
          }
        }
      },
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  /// ---------------- HUAWEI ----------------
  Future<void> _initializeHuawei() async {
    if (kDebugMode) {
      print("Initializing Huawei Push listener");
    }

    _huaweiMessageSub = hms.Push.onMessageReceivedStream
        .listen((hms.RemoteMessage message) async {
      if (kDebugMode) {
        print("Huawei notification received:");
        print("message.data: ${message.data}");
        print("message.notification?.title: ${message.notification?.title}");
        print("message.notification?.body: ${message.notification?.body}");
      }

      final Map<String, dynamic> parsedData = _parseHuaweiData(message.data);

      final String title = message.notification?.title ??
          parsedData['title']?.toString() ??
          'Plug';

      final String body = message.notification?.body ??
          parsedData['body']?.toString() ??
          'New update';

      await _showLocalNotification(
        title: title,
        body: body,
        payload: parsedData,
      );

      _handleNotification(parsedData);
    });

    _huaweiOpenSub = hms.Push.onNotificationOpenedApp.listen((dynamic data) {
      if (kDebugMode) {
        print("Huawei notification opened:");
        print(data);
      }

      if (data == null) return;

      try {
        final dataStr = data is String ? data : data.toString();
        if (dataStr.isEmpty) return;
        final parsed = jsonDecode(dataStr) as Map<String, dynamic>;
        _handleNotification(parsed);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to decode Huawei open payload: $e");
        }
      }
    });
  }

  /// ---------------- FIREBASE ----------------
  Future<void> _initializeFirebase() async {
    if (kDebugMode) {
      print("Initializing Firebase Push listener");
    }

    fcm.FirebaseMessaging.onMessage.listen((fcm.RemoteMessage message) async {
      if (kDebugMode) {
        print("Firebase notification received:");
        print(message.data);
      }

      final String title = message.notification?.title ??
          message.data['title']?.toString() ??
          'Plug';

      final String body = message.notification?.body ??
          message.data['body']?.toString() ??
          'New update';

      await _showLocalNotification(
        title: title,
        body: body,
        payload: message.data,
      );

      _handleNotification(message.data);
    });

    fcm.FirebaseMessaging.onMessageOpenedApp
        .listen((fcm.RemoteMessage message) {
      if (kDebugMode) {
        print("Notification opened:");
        print(message.data);
      }

      _handleNotification(message.data);
    });
  }

  /// ---------------- LOCAL NOTIFICATION DISPLAY ----------------
  Future<void> _showLocalNotification({
  required String title,
  required String body,
  required Map<String, dynamic> payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'plug_high_importance',
    'Plug Notifications',
    channelDescription:
        'Notifications for bookings, negotiations and updates',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const details = NotificationDetails(android: androidDetails);

  await _localNotifications.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails: details,
    payload: jsonEncode(payload),
  );
}

  /// ---------------- HELPERS ----------------
  Map<String, dynamic> _parseHuaweiData(dynamic rawData) {
    if (rawData == null) return {};

    if (rawData is Map<String, dynamic>) {
      return rawData;
    }

    if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to decode Huawei data string: $e");
        }
      }
    }

    return {};
  }

  /// ---------------- HANDLER ----------------
  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type']?.toString();

    if (kDebugMode) {
      print("Notification type: $type");
      print("Notification payload: $data");
    }

    switch (type) {
      case "order_accepted":
        if (kDebugMode) {
          print("Order accepted notification received");
        }
        break;

      case "provider_on_the_way":
        if (kDebugMode) {
          print("Provider on the way notification received");
        }
        break;

      case "provider_arrived":
        if (kDebugMode) {
          print("Provider arrived notification received");
        }
        break;

      case "negotiation_accepted":
        if (kDebugMode) {
          print("Negotiation accepted notification received");
        }
        break;

      case "test":
        if (kDebugMode) {
          print("Test notification received");
        }
        break;

      default:
        if (kDebugMode) {
          print("Unknown notification type");
        }
    }
  }

  void dispose() {
    _huaweiMessageSub?.cancel();
    _huaweiOpenSub?.cancel();
  }
}
