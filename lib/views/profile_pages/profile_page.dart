import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/views/navigation_class.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/auth_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';
import 'package:coders_adda_app/views/profile_pages/edite_profile.dart';
import 'package:coders_adda_app/views/profile_pages/my_certificates_page.dart';
import 'package:coders_adda_app/views/subscription_pages/my_subscriptions_page.dart';
import 'package:coders_adda_app/views/common/help_support_page.dart';
import 'package:coders_adda_app/views/profile_pages/payment_history_page.dart';
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
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1033),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainNavigation()),
              );
            }
          },
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1033),
          ),
        ),
        actions: [
          Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.user == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF0033CC)),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: viewModel.user!),
                    ),
                  );
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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0033CC)));
          }

          if (viewModel.errorMessage != null) {
            return RefreshIndicator(
              onRefresh: () => viewModel.fetchUserProfile(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Text('Error: ${viewModel.errorMessage}', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.fetchUserProfile(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.user == null) {
            return RefreshIndicator(
              onRefresh: () => viewModel.fetchUserProfile(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  const Center(child: Text('No profile data found')),
                ],
              ),
            );
          }

          final user = viewModel.user!;

          return RefreshIndicator(
            color: const Color(0xFF0033CC),
            onRefresh: () => viewModel.fetchUserProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth4,
                vertical: AppSizer.deviceHeight1_5,
              ),
              child: Column(
                children: [
                  _buildProfileCompletionWidget(user),
                  _buildProfileHeader(user),
                  SizedBox(height: AppSizer.deviceHeight1_5),
                  _buildLearningStats(viewModel, user),
                  SizedBox(height: AppSizer.deviceHeight1_5),
                  _buildStudentDetails(user),
                  SizedBox(height: AppSizer.deviceHeight1_5),
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

  Widget _buildProfileCompletionWidget(UserProfile user) {
    int percentage = user.calculatedProgressPercentage;
    if (percentage == 100) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizer.deviceSp13,
                  color: const Color(0xFF0B1033),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizer.deviceSp13,
                  color: const Color(0xFF0033CC),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizer.deviceHeight1),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0033CC)),
              minHeight: 7,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight0_5),
          Text(
            'Complete your profile to unlock all features.',
            style: TextStyle(
              fontSize: AppSizer.deviceSp11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: AppSizer.deviceWidth18,
                height: AppSizer.deviceWidth18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0033CC),
                  border: Border.all(
                    color: user.hasActiveSubscription
                        ? AppColors.logoOrange
                        : const Color(0xFF0033CC),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: user.profilePicture.isNotEmpty
                      ? Image.network(
                          user.profilePicture,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'P',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizer.deviceSp24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppSizer.deviceSp24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
              if (user.hasActiveSubscription)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.logoOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
          SizedBox(width: AppSizer.deviceWidth4),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B1033),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  user.mobile,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Verified badge
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0033CC).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              color: Color(0xFF0033CC),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStats(ProfileViewModel viewModel, UserProfile user) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSizer.deviceHeight2,
        horizontal: AppSizer.deviceWidth2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('₹${user.walletBalance}', 'Wallet', Icons.account_balance_wallet_rounded, Colors.green.shade600),
          _buildDivider(),
          _buildStatItem('${user.referralCount}', 'Referrals', Icons.people_rounded, const Color(0xFF0033CC)),
          _buildDivider(),
          _buildStatItem('${user.courseCount}', 'Courses', Icons.play_circle_filled, Colors.orange),
          _buildDivider(),
          _buildStatItem(viewModel.memberSince, 'Member Since', Icons.calendar_today_rounded, Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: AppSizer.deviceSp18),
        ),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizer.deviceSp13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0B1033),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizer.deviceSp10,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudentDetails(UserProfile user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizer.deviceWidth4,
              AppSizer.deviceHeight2,
              AppSizer.deviceWidth4,
              AppSizer.deviceHeight1,
            ),
            child: Text(
              'Student Details',
              style: TextStyle(
                fontSize: AppSizer.deviceSp15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B1033),
              ),
            ),
          ),
          _buildDetailRow('College', user.college, Icons.school_rounded, Colors.blue.shade700),
          _buildDetailRow('Course', user.course, Icons.menu_book_rounded, Colors.indigo),
          _buildDetailRow('Branch', user.branch, Icons.account_tree_rounded, Colors.teal),
          _buildDetailRow('Semester', user.semester, Icons.timeline_rounded, Colors.deepOrange),
          _buildDetailRow('Technology', user.technology.join(', '), Icons.computer_rounded, Colors.purple),
          SizedBox(height: AppSizer.deviceHeight1),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color iconColor) {
    final bool isEmpty = value.trim().isEmpty || value == 'null';
    return Column(
      children: [
        Divider(height: 1, color: Colors.grey.shade100),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizer.deviceWidth4,
            vertical: AppSizer.deviceHeight1_5,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: AppSizer.deviceSp16),
              ),
              SizedBox(width: AppSizer.deviceWidth3),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0B1033),
                  ),
                ),
              ),
              Text(
                isEmpty ? 'Not Added' : value,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp13,
                  fontWeight: FontWeight.w500,
                  color: isEmpty ? const Color(0xFF0033CC) : Colors.grey.shade700,
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth1),
              Icon(
                Icons.chevron_right_rounded,
                size: AppSizer.deviceSp16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.play_lesson_rounded,
        'title': 'My Courses',
        'color': const Color(0xFF0033CC),
        'onTap': () { NavigationService.navigateTo(context, MyLearningPage()); },
      },
      {
        'icon': Icons.receipt_long_rounded,
        'title': 'Payment History',
        'color': Colors.orange,
        'onTap': () { NavigationService.navigateTo(context, const PaymentHistoryPage()); },
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'title': 'My Certificates',
        'color': Colors.green.shade600,
        'onTap': () { NavigationService.navigateTo(context, const MyCertificatesPage()); },
      },
      {
        'icon': Icons.card_membership_rounded,
        'title': 'My Subscription',
        'color': Colors.deepOrange,
        'onTap': () { NavigationService.navigateTo(context, MySubscriptionsPage()); },
      },
      {
        'icon': Icons.help_rounded,
        'title': 'Help & Support',
        'color': Colors.blue,
        'onTap': () { NavigationService.navigateTo(context, const HelpSupportPage()); },
      },
      {
        'icon': Icons.logout_rounded,
        'title': 'Logout',
        'color': Colors.red,
        'onTap': () { _showLogoutDialog(context); },
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final color = item['color'] as Color;
            return Column(
              children: [
                if (index > 0) Divider(height: 1, color: Colors.grey.shade100),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth4,
                    vertical: AppSizer.deviceHeight0_5,
                  ),
                  leading: Container(
                    padding: EdgeInsets.all(AppSizer.deviceWidth2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: color,
                      size: AppSizer.deviceSp18,
                    ),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0B1033),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: AppSizer.deviceSp20,
                    color: Colors.grey.shade400,
                  ),
                  onTap: item['onTap'] as VoidCallback,
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    String finalUrl = urlString;
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }
    final Uri url = Uri.parse(finalUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link format')),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) {
                context.read<ProfileViewModel>().clearProfile();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
