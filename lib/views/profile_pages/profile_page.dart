import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';
import 'package:coders_adda_app/views/profile_pages/edite_profile.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.user == null) return SizedBox();
              return IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: viewModel.user!),
                    ),
                  );
                  // Refresh profile when coming back from Edit Profile
                  viewModel.fetchUserProfile();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchUserProfile(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.user == null) {
            return Center(child: Text('No Profile Data Found'));
          }

          final user = viewModel.user!;

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchUserProfile(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildLearningStats(viewModel, user),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildStudentDetails(user),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildSkillsSection(user),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildAchievementsSection(viewModel.achievements),
                  SizedBox(height: AppSizer.deviceHeight1),
                  _buildMenuItems(context),
                  SizedBox(height: AppSizer.deviceHeight4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          children: [
            // Profile Image and Basic Info
            Row(
              children: [
                // Profile Image
                Container(
                  width: AppSizer.deviceWidth20,
                  height: AppSizer.deviceWidth20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 3),
                    image: DecorationImage(
                      image: NetworkImage(
                        user.profilePicture.isNotEmpty 
                        ? user.profilePicture 
                        : "https://via.placeholder.com/150"
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(width: AppSizer.deviceWidth4),

                // Basic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight0_5),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: AppSizer.deviceSp16,
                        ),
                      ),
                      SizedBox(height: AppSizer.deviceHeight0_5),
                      Text(
                        user.mobile,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: AppSizer.deviceSp16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Verification Badge
                Container(
                  padding: EdgeInsets.all(AppSizer.deviceWidth2),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    color: AppColors.successColor,
                    size: AppSizer.deviceSp20,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizer.deviceHeight2),

            // Bio
            Text(
              user.about,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSizer.deviceHeight2),

            // Social Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.code, 'GitHub', () {
                  _launchUrl(user.github);
                }),
                SizedBox(width: AppSizer.deviceWidth3),
                _buildSocialButton(Icons.work, 'LinkedIn', () {
                  _launchUrl(user.linkedin);
                }),
                SizedBox(width: AppSizer.deviceWidth3),
                _buildSocialButton(Icons.public, 'Portfolio', () {
                  _launchUrl(user.portfolio);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizer.deviceWidth3,
          vertical: AppSizer.deviceHeight1,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: AppSizer.deviceSp16,
            ),
            SizedBox(width: AppSizer.deviceWidth1),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningStats(ProfileViewModel viewModel, UserProfile user) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '${user.walletBalance}',
              'Wallet',
              Icons.account_balance_wallet,
              AppColors.successColor,
            ),
            _buildStatItem(
              '${user.referralCount}',
              'Referrals',
              Icons.group,
              AppColors.primaryColor,
            ),
            _buildStatItem(
               '0', // Placeholder for now
              'Courses',
              Icons.play_circle_filled,
              Colors.orange,
            ),
            _buildStatItem(
              viewModel.memberSince,
              'Member Since',
              Icons.calendar_today,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: AppSizer.deviceSp20),
        ),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizer.deviceSp18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp14,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudentDetails(UserProfile user) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Details',
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            _buildDetailRow('College', user.college, Icons.school),
            _buildDetailRow('Course', user.course, Icons.menu_book),
            _buildDetailRow('Branch', user.branch, Icons.account_tree),
            _buildDetailRow('Semester', user.semester, Icons.timeline),
            _buildDetailRow('Technology', user.technology.join(", "), Icons.computer),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: AppSizer.deviceSp20),
          SizedBox(width: AppSizer.deviceWidth3),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizer.deviceSp16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(UserProfile user) {
    final skills = user.skills;

    return Container(
      //height: ,
      width: double.infinity,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills & Technologies',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight2),
              Wrap(
                spacing: AppSizer.deviceWidth2,
                runSpacing: AppSizer.deviceHeight1,
                children: skills
                    .map(
                      (skill) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth3,
                          vertical: AppSizer.deviceHeight1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          skill.trim(),
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(List<Achievement> achievements) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth2,
                    vertical: AppSizer.deviceHeight0_5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${achievements.length} Badges',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Column(
              children: achievements
                  .map((achievement) => _buildAchievementItem(achievement))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      padding: EdgeInsets.all(AppSizer.deviceWidth3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          // Achievement Icon
          Container(
            width: AppSizer.deviceWidth12,
            height: AppSizer.deviceWidth12,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(fontSize: AppSizer.deviceSp18),
              ),
            ),
          ),

          SizedBox(width: AppSizer.deviceWidth3),

          // Achievement Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.video_library,
        'title': 'My Courses',
        'color': AppColors.primaryColor,
        'onTap': () {
          NavigationService.navigateTo(context, MyLearningPage());
        },
      },

      {
        'icon': Icons.workspace_premium,
        'title': 'My Subscription',
        'color': Colors.amber,
        'onTap': () {
          NavigationService.navigateTo(context, SubscriptionPage());
        },
      },
      // {
      //   'icon': Icons.local_offer,
      //   'title': 'Apply Coupon',
      //   'color': Colors.green,
      //   'onTap': () {
      //     NavigationService.navigateTo(context, CouponPage());
      //   }
      // },
      // {
      //   'icon': Icons.settings,
      //   'title': 'Settings',
      //   'color': Colors.grey,
      //   'onTap': () {
      //     _showComingSoon(context);
      //   },
      // },
      {
        'icon': Icons.help,
        'title': 'Help & Support',
        'color': Colors.blue,
        'onTap': () {
          _showComingSoon(context);
        },
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'color': Colors.red,
        'onTap': () {
          _showLogoutDialog(context);
        },
      },
    ];

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: menuItems.map((item) {
            return ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth2),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: AppSizer.deviceSp20,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(fontSize: AppSizer.deviceSp16),
              ),
              trailing: Container(
                padding: EdgeInsets.all(AppSizer.deviceWidth1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizer.deviceSp14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              onTap: item['onTap'] as VoidCallback,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Text('Edit profile feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) {
    // Implement URL launching
    print('Launching: $url');
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('This feature is under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) {
                context.read<ProfileViewModel>().clearProfile();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
