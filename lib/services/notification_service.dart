import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/main.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/views/home_pages/all_course_details_page.dart';
import 'package:coders_adda_app/views/buy_new_pdf_pages/pdf_detail_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_player_page.dart';
import 'package:coders_adda_app/views/common/help_support_page.dart';
import 'package:coders_adda_app/views/my_owened_pdf/offline_pdfs_page.dart';
import 'package:coders_adda_app/views/register_pages/login_page.dart';
import 'package:coders_adda_app/services/auth_service.dart';

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
      if (message.data['type'] == 'LOGIN_APPROVAL_REQUEST') {
        _showLoginApprovalDialog();
        return; // Don't show standard notification for this
      }

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
    if (actionLink.isEmpty) return;
    
    // Retry mechanism for cold start (when navigatorKey is not ready yet)
    _tryNavigate(actionLink, 0);
  }

  void _tryNavigate(String actionLink, int attempts) {
    if (attempts > 10) {
      debugPrint('[DeepLink] Navigator never became ready. Aborting deep link.');
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      // Navigator is not ready yet, wait and try again
      Future.delayed(const Duration(milliseconds: 500), () {
        _tryNavigate(actionLink, attempts + 1);
      });
      return;
    }

    // Use post-frame callback so app is ready to navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (actionLink.startsWith('/course-detail/') || 
            actionLink.startsWith('/course/') || 
            actionLink.startsWith('/class-detail/') || 
            actionLink.startsWith('/class/')) {
          
          String courseId = actionLink
              .replaceFirst('/course-detail/', '')
              .replaceFirst('/course/', '')
              .replaceFirst('/class-detail/', '')
              .replaceFirst('/class/', '');
              
          navigator.push(MaterialPageRoute(builder: (_) => MyLearningCoursePlayer(courseId: courseId)));
          debugPrint('[DeepLink] Course detail: $courseId - opened course player');
        }
        else if (actionLink.startsWith('/ebook-details/')) {
          final ebookId = actionLink.replaceFirst('/ebook-details/', '');
          final dummyPdf = PdfItem(
            id: ebookId, title: 'Loading...', description: '', fileSize: '', category: '', categoryId: '', isFree: false, priceType: 'paid', downloadUrl: '', thumbnail: '', uploadedAt: DateTime.now(), author: '', isActive: true
          );
          navigator.push(MaterialPageRoute(builder: (_) => PdfDetailPage(pdf: dummyPdf)));
        }
        else if (actionLink.startsWith('/course-test/')) {
          final courseId = actionLink.replaceFirst('/course-test/', '');
          navigator.push(MaterialPageRoute(builder: (_) => MyLearningCoursePlayer(courseId: courseId)));
        }
        else if (actionLink.trim().toLowerCase() == '/quiz') {
          navigator.pushNamed('/quiz');
        }
        else if (actionLink == '/subscription') {
          navigator.pushNamed('/subscription');
        }
        else if (actionLink == '/jobs' || actionLink == '/job') {
          navigator.pushNamed('/job');
        }
        else if (actionLink == '/certificates' || actionLink == '/my-certificates') {
          navigator.pushNamed('/certificates');
        }
        else if (actionLink == '/support') {
          navigator.push(MaterialPageRoute(builder: (_) => const HelpSupportPage(initialIndex: 1)));
        }
        else if (actionLink == '/downloads') {
          navigator.push(MaterialPageRoute(builder: (_) => OfflinePdfsPage()));
        }
        else {
          debugPrint('[DeepLink] Unhandled link: $actionLink');
        }
      } catch (e) {
        debugPrint('[DeepLink] Navigation error: $e');
      }
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'codersadda_notifications',
          'General Notifications',
          channelDescription: 'Notifications for CodersAdda updates',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> scheduleProfileCompletionReminder() async {
    await _localNotificationsPlugin.periodicallyShow(
      id: 999, // Specific ID for profile reminder
      title: 'Complete Your Profile!',
      body: 'Your profile is incomplete. Complete it now to unlock all features and recommendations.',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'codersadda_notifications',
          'General Notifications',
          channelDescription: 'Notifications for CodersAdda updates',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: '/profile', // You can handle this in deep links if you add '/profile'
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  Future<void> cancelProfileCompletionReminder() async {
    await _localNotificationsPlugin.cancel(id: 999);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();
  }

  // Token refresh listener
  void listenToTokenRefresh(Function(String) onTokenRefresh) {
    _fcm.onTokenRefresh.listen(onTokenRefresh);
  }

  void _showLoginApprovalDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Login Attempt"),
          content: const Text("Another device is trying to log into your account. Do you want to allow them and log out from this device?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text("Deny")
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authService = AuthService();
                await authService.approveLogin();
                await authService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Allow & Logout"),
            ),
          ],
        );
      }
    );
  }
}
