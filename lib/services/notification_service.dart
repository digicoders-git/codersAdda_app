import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/main.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Background messaging handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // We need payload in response if we set it in .show()
        if (response.payload != null && response.payload!.isNotEmpty) {
           _handleDeepLink(response.payload!);
        }
      },
    );

    // Create a channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'codersadda_notifications', // id
      'General Notifications', // title
      description: 'Notifications for CodersAdda updates',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground messaging listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          payload: message.data['actionLink'],
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Handle background taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       if (message.data.containsKey('actionLink')) {
          _handleDeepLink(message.data['actionLink']);
       }
    });

    // Handle cold start taps
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.data.containsKey('actionLink')) {
         _handleDeepLink(message.data['actionLink']);
      }
    });
    
    _isInitialized = true;
  }

  void _handleDeepLink(String actionLink) {
     if (actionLink.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(actionLink);
     }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Token refresh listener
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _fcm.onTokenRefresh.listen(onTokenRefresh);
  }
}
