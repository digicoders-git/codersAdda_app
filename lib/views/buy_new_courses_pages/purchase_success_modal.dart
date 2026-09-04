import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class PurchaseSuccessModal extends StatelessWidget {
  final String title;
  final String itemType;
  final VoidCallback onGoToMyLearning;
  final List<String>? customBenefits;
  final VoidCallback? onClose;

  const PurchaseSuccessModal({
    Key? key,
    required this.title,
    required this.itemType,
    required this.onGoToMyLearning,
    this.customBenefits,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth6,
          vertical: AppSizer.deviceHeight3,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative background blobs
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0EDFF).withOpacity(0.7),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDCFCE7).withOpacity(0.6),
                ),
              ),
            ),

            // Modal Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth5,
                vertical: AppSizer.deviceHeight3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration Graphic (Graduation Cap + Confetti + Green Checkmark)
                  _buildCelebrationHeader(),

                  SizedBox(height: AppSizer.deviceHeight2),

                  // Heading
                  Text(
                    _getSuccessTitle(),
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSizer.deviceHeight1),

                  // Subtitle
                  Text(
                    'You are now part of the learning journey.\nHappy Learning! 💙',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp13,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSizer.deviceHeight2_5),

                  // Feature / Benefits List Card
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer.deviceWidth4,
                      vertical: AppSizer.deviceHeight1_5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildBenefitsList(),
                    ),
                  ),

                  SizedBox(height: AppSizer.deviceHeight3),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      // Close Button
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
                            if (onClose != null) {
                              onClose!();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: const Color(0xFF0052FF),
                              fontSize: AppSizer.deviceSp14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth3),

                      // Go to My Learning Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onGoToMyLearning();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052FF),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Go to My Learning',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizer.deviceSp14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return SizedBox(
      width: 170,
      height: 135,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Light blue circular glow
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF3FE),
              shape: BoxShape.circle,
            ),
          ),

          // Confetti particles around the cap
          Positioned(
            top: 14,
            left: 28,
            child: _buildConfettiParticle(color: const Color(0xFF2563EB), angle: -0.4, width: 14, height: 5),
          ),
          Positioned(
            top: 24,
            left: 14,
            child: _buildConfettiParticle(color: const Color(0xFFF59E0B), angle: 0.6, width: 12, height: 4),
          ),
          Positioned(
            bottom: 38,
            left: 20,
            child: _buildConfettiParticle(color: const Color(0xFF10B981), angle: 0.8, width: 8, height: 8, isCircle: true),
          ),
          Positioned(
            top: 14,
            right: 32,
            child: _buildConfettiParticle(color: const Color(0xFFF59E0B), angle: 0.5, width: 14, height: 5),
          ),
          Positioned(
            top: 28,
            right: 18,
            child: _buildConfettiParticle(color: const Color(0xFF10B981), angle: -0.5, width: 10, height: 4),
          ),
          Positioned(
            bottom: 44,
            right: 16,
            child: _buildConfettiParticle(color: const Color(0xFF2563EB), angle: 0.3, width: 9, height: 5),
          ),
          Positioned(
            bottom: 26,
            right: 30,
            child: _buildConfettiParticle(color: const Color(0xFFF59E0B), angle: 0.7, width: 6, height: 6, isCircle: true),
          ),

          // Graduation Cap
          Positioned(
            top: 12,
            child: const Icon(
              Icons.school_rounded,
              size: 78,
              color: Color(0xFF0052FF),
            ),
          ),

          // Green Checkmark badge overlapping bottom of the cap
          Positioned(
            bottom: 0,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiParticle({
    required Color color,
    required double angle,
    required double width,
    required double height,
    bool isCircle = false,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isCircle ? width / 2 : 2),
        ),
      ),
    );
  }

  String _getSuccessTitle() {
    switch (itemType) {
      case 'ebook':
        return 'PDF Successfully\nPurchased!';
      case 'subscription':
        return 'Subscription\nActivated!';
      case 'job':
        return 'Job Application\nSubmitted!';
      default:
        return 'Course Successfully\nEnrolled!';
    }
  }

  List<Widget> _buildBenefitsList() {
    if (customBenefits != null && customBenefits!.isNotEmpty) {
      final List<IconData> defaultIcons = [
        Icons.all_inclusive_rounded,
        Icons.file_download_outlined,
        Icons.workspace_premium_outlined,
        Icons.headset_mic_outlined,
      ];
      final List<Color> iconColors = [
        const Color(0xFF2563EB),
        const Color(0xFF16A34A),
        const Color(0xFFEA580C),
        const Color(0xFF9333EA),
      ];
      final List<Color> bgColors = [
        const Color(0xFFEFF6FF),
        const Color(0xFFF0FDF4),
        const Color(0xFFFFF7ED),
        const Color(0xFFFAF5FF),
      ];

      return List.generate(customBenefits!.length, (index) {
        final b = customBenefits![index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == customBenefits!.length - 1 ? 0 : AppSizer.deviceHeight1_5,
          ),
          child: _buildFeatureRow(
            icon: defaultIcons[index % defaultIcons.length],
            iconColor: iconColors[index % iconColors.length],
            bgColor: bgColors[index % bgColors.length],
            title: b,
            subtitle: 'Included with your enrollment',
          ),
        );
      });
    }

    switch (itemType) {
      case 'ebook':
        return [
          _buildFeatureRow(
            icon: Icons.all_inclusive_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            title: 'Lifetime Access',
            subtitle: 'Read anytime, anywhere',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.file_download_outlined,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFF0FDF4),
            title: 'Download Resources',
            subtitle: 'Offline PDF & study materials',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.devices_outlined,
            iconColor: const Color(0xFFEA580C),
            bgColor: const Color(0xFFFFF7ED),
            title: 'Multi-Device Support',
            subtitle: 'Read on phone, tablet & PC',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.headset_mic_outlined,
            iconColor: const Color(0xFF9333EA),
            bgColor: const Color(0xFFFAF5FF),
            title: '24/7 Support',
            subtitle: 'Get help anytime',
          ),
        ];
      case 'subscription':
        return [
          _buildFeatureRow(
            icon: Icons.all_inclusive_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            title: 'All Courses & PDFs Access',
            subtitle: 'Unlimited access to everything',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.file_download_outlined,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFF0FDF4),
            title: 'Download Resources',
            subtitle: 'Save videos & study materials',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.workspace_premium_outlined,
            iconColor: const Color(0xFFEA580C),
            bgColor: const Color(0xFFFFF7ED),
            title: 'Certificates Included',
            subtitle: 'Boost your resume & profile',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.headset_mic_outlined,
            iconColor: const Color(0xFF9333EA),
            bgColor: const Color(0xFFFAF5FF),
            title: 'Priority Support',
            subtitle: 'Dedicated mentor assistance',
          ),
        ];
      default:
        return [
          _buildFeatureRow(
            icon: Icons.all_inclusive_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            title: 'Lifetime Access',
            subtitle: 'Learn at your own pace',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.file_download_outlined,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFF0FDF4),
            title: 'Download Resources',
            subtitle: 'Access all study materials',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.workspace_premium_outlined,
            iconColor: const Color(0xFFEA580C),
            bgColor: const Color(0xFFFFF7ED),
            title: 'Certificate on Completion',
            subtitle: 'Boost your profile',
          ),
          SizedBox(height: AppSizer.deviceHeight1_5),
          _buildFeatureRow(
            icon: Icons.headset_mic_outlined,
            iconColor: const Color(0xFF9333EA),
            bgColor: const Color(0xFFFAF5FF),
            title: '24/7 Support',
            subtitle: 'Get help anytime',
          ),
        ];
    }
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        SizedBox(width: AppSizer.deviceWidth3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context, {
    required String title,
    required String itemType,
    required VoidCallback onGoToMyLearning,
    List<String>? customBenefits,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PurchaseSuccessModal(
        title: title,
        itemType: itemType,
        onGoToMyLearning: onGoToMyLearning,
        customBenefits: customBenefits,
        onClose: onClose,
      ),
    );
  }

  static int getTabIndexForItemType(String itemType, bool isFree) {
    if (itemType == 'ebook') {
      return isFree ? 2 : 3; // Free E-Books: 2, Premium E-Books: 3
    } else {
      return isFree ? 0 : 1; // Free Courses: 0, Premium Courses: 1
    }
  }
}
