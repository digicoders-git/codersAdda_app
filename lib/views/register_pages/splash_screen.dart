// views/splash_screen.dart
import 'package:coders_adda_app/views/register_pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/notification_service.dart';
import 'package:coders_adda_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    final apiClient = ApiClient();
    final token = await apiClient.getToken();
    
    if (token != null && token.isNotEmpty) {
      try {
        final fcmToken = await NotificationService().getToken();
        if (fcmToken != null) {
          await AuthService().updateFcmToken(fcmToken);
        }
      } catch (e) {
        print("FCM Token init error: $e");
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, token != null && token.isNotEmpty ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizer.deviceWidth80,
              padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth5),
              child: Image.asset(
                "assets/images/mainLogo.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'Learn • Grow • Succeed',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizer.deviceSp16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
