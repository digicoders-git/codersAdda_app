import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/views/navigation_class.dart';
import 'package:coders_adda_app/views/shorts_pages/shorts_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:coders_adda_app/views/register_pages/splash_screen.dart';
import 'package:coders_adda_app/views/register_pages/login_page.dart';
import 'package:coders_adda_app/views/job_pages/job_page.dart';
import 'package:coders_adda_app/views/quiz_program_pages/quiz_page.dart';
import 'package:coders_adda_app/services/home_cache_service.dart';
import 'package:coders_adda_app/services/offline_pdf_service.dart';
import 'package:coders_adda_app/views/profile_pages/my_certificates_page.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/notification_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/job_application_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/my_learning_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/wishlist_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:coders_adda_app/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  await HomeCacheService.init();
  await OfflinePdfService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => JobApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => MyLearningViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
      ],
      child: LearningApp(),
    ),
  );
}

class LearningApp extends StatefulWidget {
  @override
  _LearningAppState createState() => _LearningAppState();
}

class _LearningAppState extends State<LearningApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was cold started
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Failed to get initial app link: $e");
    }

    // Handle link when app is in warm state (foreground/background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint("Failed to get app link stream: $err");
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.contains('/short')) {
      final shortId = uri.queryParameters['id'];
      if (shortId != null && shortId.isNotEmpty) {
        // Wait for navigator to be ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (navigatorKey.currentState != null) {
             navigatorKey.currentState!.pushNamed(
               '/shorts',
               arguments: {'shortId': shortId},
             );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Coders Adda',
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          home: SplashScreen(), 
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => MainNavigation(),
            '/shorts': (context) => ShortsPage(),
            '/subscription': (context) => SubscriptionPage(),
            '/jobs': (context) => JobsPage(),
            '/job': (context) => JobsPage(),
            '/quiz': (context) => QuizPage(),
            '/certificates': (context) => const MyCertificatesPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
