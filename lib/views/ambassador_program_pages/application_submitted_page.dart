import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_rewards_page.dart';
import 'package:coders_adda_app/views/ambassador_program_pages/ambassador_status_hub_page.dart';

class ApplicationSubmittedPage extends StatelessWidget {
  final Map<String, dynamic>? initialData;

  const ApplicationSubmittedPage({super.key, this.initialData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1033)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/mainLogo.png',
          height: AppSizer.deviceHeight10,
          fit: BoxFit.contain,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth5,
          vertical: AppSizer.deviceHeight2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSizer.deviceHeight1),

            // 3D Checklist Illustration
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_submitted.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 80),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),

            // Title & Subtitle
            Text(
              'Application Submitted!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B1033),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight0_5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
              child: Text(
                'Thank you for showing interest in becoming a Campus Ambassador.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight2_5),

            // Review Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF0052FF),
                      size: 22,
                    ),
                  ),
                  SizedBox(width: AppSizer.deviceWidth3_5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our team will review your application and get back to you soon.',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B1033),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),
                        Text(
                          'You will be notified via email and in-app notification.',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // Go to Dashboard Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmbassadorStatusHubPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3_5),

            // Meanwhile you can section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Meanwhile, you can:',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B1033),
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1_5),

            _buildActionItem(
              iconEmoji: '₹',
              iconBgColor: const Color(0xFFFFFBEB),
              iconTextColor: const Color(0xFFF59E0B),
              title: 'Learn more about the program',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AmbassadorRewardsPage()),
                );
              },
            ),
            SizedBox(height: AppSizer.deviceHeight1),

            _buildActionItem(
              iconData: Icons.share_rounded,
              iconBgColor: const Color(0xFFEFF6FF),
              iconTextColor: const Color(0xFF0052FF),
              title: 'Share CodersAdda with friends',
              onTap: () {
                Share.share(
                  'Learn coding, programming, and build real-world skills on CodersAdda! Download now: https://codersadda.com',
                  subject: 'Check out CodersAdda!',
                );
              },
            ),
            SizedBox(height: AppSizer.deviceHeight1),

            _buildActionItem(
              iconData: Icons.school_rounded,
              iconBgColor: const Color(0xFFF3E8FF),
              iconTextColor: const Color(0xFF8B5CF6),
              title: 'Explore our courses',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            SizedBox(height: AppSizer.deviceHeight3),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    String? iconEmoji,
    IconData? iconData,
    required Color iconBgColor,
    required Color iconTextColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizer.deviceWidth4,
              vertical: AppSizer.deviceHeight1_5,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: iconEmoji != null
                        ? Text(
                            iconEmoji,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: iconTextColor,
                            ),
                          )
                        : Icon(iconData, color: iconTextColor, size: 20),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3_5),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B1033),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
