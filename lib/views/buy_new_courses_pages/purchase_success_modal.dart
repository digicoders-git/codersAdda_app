import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:lottie/lottie.dart';
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizer.deviceWidth6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: AppSizer.deviceWidth25,
              height: AppSizer.deviceWidth25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.successColor,
                size: AppSizer.deviceSp48,
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // Success Title
            Text(
              '🎉 Congratulations!',
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSizer.deviceHeight2),

            // Success Message
            Text(
              _getSuccessMessage(),
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.w600,
                color: AppColors.logoNavy,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSizer.deviceHeight2),

            // Item Title
            Container(
              padding: EdgeInsets.all(AppSizer.deviceWidth3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: AppSizer.deviceHeight3),

            // Benefits List
            ..._getBenefits().map((benefit) => _buildBenefitItem(benefit)),

            SizedBox(height: AppSizer.deviceHeight4),

            // Action Buttons
            Row(
              children: [
                Expanded(
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
                      side: BorderSide(color: AppColors.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizer.deviceWidth3),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onGoToMyLearning();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Go to My Learning',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  String _getSuccessMessage() {
    switch (itemType) {
      case 'ebook':
        return 'PDF Successfully Purchased!';
      case 'subscription':
        return 'Subscription Activated Successfully!';
      case 'job':
        return 'Job Application Submitted!';
      default:
        return 'Course Successfully Enrolled!';
    }
  }

  List<String> _getBenefits() {
    if (customBenefits != null && customBenefits!.isNotEmpty) {
      return customBenefits!.map((b) => '✓ $b').toList();
    }

    switch (itemType) {
      case 'ebook':
        return [
          '✓ Lifetime Access',
          '✓ Download Anytime',
          '✓ Read Offline',
          '✓ 24/7 Support',
        ];
      case 'subscription':
        return [
          '✓ Access All Courses',
          '✓ Premium Content',
          '✓ Priority Support',
          '✓ Exclusive Benefits',
        ];
      case 'job':
        return [
          '✓ Application Submitted',
          '✓ Profile Reviewed',
          '✓ Updates via Email',
          '✓ Direct Contact',
        ];
      default:
        return [
          '✓ Lifetime Access',
          '✓ Download Resources',
          '✓ Certificate on Completion',
          '✓ 24/7 Support',
        ];
    }
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.successColor,
            size: AppSizer.deviceSp16,
          ),
          SizedBox(width: AppSizer.deviceWidth2),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizer.deviceSp14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
