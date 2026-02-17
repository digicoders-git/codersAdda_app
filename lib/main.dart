import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/views/navigation_class.dart';
import 'package:coders_adda_app/views/shorts_pages/shorts_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:coders_adda_app/views/register_pages/splash_screen.dart';
import 'package:coders_adda_app/views/register_pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
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
          theme: AppTheme.lightTheme,
          home: SplashScreen(), 
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => MainNavigation(),
            '/shorts': (context) => ShortsPage(),
            '/subscription': (context) => SubscriptionPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
