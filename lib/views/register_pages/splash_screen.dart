// views/splash_screen.dart
import 'package:coders_adda_app/views/register_pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/services/api_client.dart';

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
    await Future.delayed(Duration(seconds: 2));

    final apiClient = ApiClient();
    final token = await apiClient.getToken();

    if (token != null && token.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizer.deviceWidth20,
              height: AppSizer.deviceWidth20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/images/codersaddalogo.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight4),
            Text(
              'CodersAdda',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer.deviceSp28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'Learn • Grow • Succeed',
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppSizer.deviceSp16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
