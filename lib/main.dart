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

import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/notification_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/job_application_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/my_learning_viewmodel.dart';
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
      ],
      child: LearningApp(),
    ),
  );
}

class LearningApp extends StatelessWidget {
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
