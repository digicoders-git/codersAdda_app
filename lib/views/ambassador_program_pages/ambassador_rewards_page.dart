import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class AmbassadorRewardsPage extends StatelessWidget {
  const AmbassadorRewardsPage({super.key});

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
            // 3D Gift illustration
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/gift_rewards.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎁', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),

            // Heading & Subheading
            Text(
              'Earn While You Help Others Learn!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B1033),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight0_5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth3),
              child: Text(
                'As a Campus Ambassador, you get exclusive rewards and opportunities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  color: Colors.grey.shade600,
                  height: 1.35,
                ),
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // 4 Benefit Cards
            _buildBenefitRow(
              icon: Icons.currency_rupee_rounded,
              title: '₹200 Cashback',
              subtitle: 'Per successful referral',
              bgColor: const Color(0xFFFFFBEB),
              borderColor: const Color(0xFFFDE68A),
              iconBgColor: const Color(0xFFF59E0B),
            ),
            SizedBox(height: AppSizer.deviceHeight1_5),

            _buildBenefitRow(
              icon: Icons.workspace_premium_rounded,
              title: 'Certificate',
              subtitle: 'Get an official Campus Ambassador certificate',
              bgColor: const Color(0xFFECFDF5),
              borderColor: const Color(0xFFA7F3D0),
              iconBgColor: const Color(0xFF10B981),
            ),
            SizedBox(height: AppSizer.deviceHeight1_5),

            _buildBenefitRow(
              icon: Icons.star_rounded,
              title: 'Exclusive Perks',
              subtitle: 'Early access to courses & events',
              bgColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFED7AA),
              iconBgColor: const Color(0xFFF97316),
            ),
            SizedBox(height: AppSizer.deviceHeight1_5),

            _buildBenefitRow(
              icon: Icons.groups_rounded,
              title: 'Build Your Network',
              subtitle: 'Connect with like-minded learners',
              bgColor: const Color(0xFFFAF5FF),
              borderColor: const Color(0xFFE9D5FF),
              iconBgColor: const Color(0xFF8B5CF6),
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // Quote Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                children: [
                  Text(
                    '“Learn. Share. Grow Together!”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0033CC),
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight0_5),
                  Text(
                    '— CodersAdda',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp12,
                      color: const Color(0xFF0033CC).withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    required Color iconBgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizer.deviceWidth3_5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBgColor, size: 24),
          ),
          SizedBox(width: AppSizer.deviceWidth3_5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B1033),
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  subtitle,
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
    );
  }
}
