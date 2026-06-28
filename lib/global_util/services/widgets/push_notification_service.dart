import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/widgets/app_notification_helper.dart';
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
  final event = data['event']?.toString() ?? data['type']?.toString();

  if (kDebugMode) {
    print("Event received: $event");
    print("Payload: $data");
  }

  switch (event) {
    // ---------------- ORDERS ----------------
    case "order.created":
      _onOrderCreated(data);
      break;

    case "order.accepted":
      _onOrderAccepted(data);
      break;

    case "order.canceled":
      _onOrderCanceled(data);
      break;

    // ---------------- NEGOTIATION ----------------
    case "negotiation.round_created":
      _onNegotiationRoundCreated(data);
      break;

    case "negotiation.accepted":
      _onNegotiationAccepted(data);
      break;

    // ---------------- SHIPMENT ----------------
    case "shipment.in_transit":
      _onShipmentInTransit(data);
      break;

    case "shipment.arrived":
      _onShipmentArrived(data);
      break;

    default:
      if (kDebugMode) {
        print("Unhandled event: $event");
      }
  }
}

void _onOrderCreated(Map<String, dynamic> data) {
  if (kDebugMode) {
    print("Order created event");
  }

  // TODO: refresh orders list / update state
}


void _onOrderAccepted(Map<String, dynamic> data) {
  if (kDebugMode) {
    print("Order accepted");
  }

  // Example:
  // navigate to tracking screen or update provider dashboard
}

void _onOrderCanceled(Map<String, dynamic> data) {
  if (kDebugMode) {
    print("Order canceled");
  }
}



void _onNegotiationRoundCreated(Map<String, dynamic> data) {
  final negotiationId = int.tryParse(data['negotiation_id'].toString());
  final orderId = int.tryParse(data['order_id'].toString());

  if (kDebugMode) {
    print("Negotiation round created: $data");
  }

  if (negotiationId == null || orderId == null) return;

  AppEventRouter.handle(
    AppEvent.negotiationRoundCreated(
      orderId: orderId,
      negotiationId: negotiationId,
      payload: data,
    ),
  );
}


void _onShipmentInTransit(Map<String, dynamic> data) {
  if (kDebugMode) {
    print("Negotiation round created");
  }

  // Example:
  // refresh negotiation screen stream / socket fallback
}

void _onShipmentArrived(Map<String, dynamic> data) {
  if (kDebugMode) {
    print("Order canceled");
  }
}

void _onNegotiationAccepted(Map<String, dynamic> data)
 {
  if (kDebugMode) {
    print("Order canceled");
  }
}



  void dispose() {
    _huaweiMessageSub?.cancel();
    _huaweiOpenSub?.cancel();
  }
}
