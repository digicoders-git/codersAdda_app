import 'package:flutter/material.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: AppSizer.deviceSp20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        children: [
          _buildSectionHeader('Today'),
          SizedBox(height: AppSizer.deviceHeight2),
          _buildNotificationCard(
            icon: Icons.work_outline,
            title: 'New Job Alert',
            description: 'Flutter Developer position at TechCorp matches your profile',
            time: '2 hours ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.event_available,
            title: 'Training Reminder',
            description: 'Your Flutter training session starts in 30 minutes',
            time: '1 hour ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.celebration,
            title: 'Welcome to Coders Adda!',
            description: 'Start exploring job opportunities and training programs',
            time: '30 minutes ago',
            isRead: true,
          ),

          SizedBox(height: AppSizer.deviceHeight4),

          // Yesterday Section
          _buildSectionHeader('Yesterday'),
          SizedBox(height: AppSizer.deviceHeight2),
          _buildNotificationCard(
            icon: Icons.update,
            title: 'Application Status',
            description: 'Your application for Senior Developer has been viewed by the company',
            time: '1 day ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.school,
            title: 'Course Update',
            description: 'New module added to your Flutter Development course',
            time: '1 day ago',
            isRead: true,
          ),

          SizedBox(height: AppSizer.deviceHeight4),

          // This Week Section
          _buildSectionHeader('This Week'),
          SizedBox(height: AppSizer.deviceHeight2),
          _buildNotificationCard(
            icon: Icons.trending_up,
            title: 'Profile Strength',
            description: 'Your profile is now 85% complete. Add more skills to get better job matches!',
            time: '2 days ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.group,
            title: 'Community Event',
            description: 'Join our Flutter Community Meetup this weekend at Tech Park',
            time: '3 days ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.workspace_premium,
            title: 'Subscription Reminder',
            description: 'Upgrade to premium to unlock all job details and apply for premium positions',
            time: '4 days ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.new_releases,
            title: 'New Features',
            description: 'We have added new job categories and improved the application process',
            time: '5 days ago',
            isRead: true,
          ),

          SizedBox(height: AppSizer.deviceHeight8),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: AppSizer.deviceSp18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required bool isRead,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      color: isRead ? AppColors.cardColor : AppColors.primaryColor.withOpacity(0.05),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: EdgeInsets.all(AppSizer.deviceWidth3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: AppSizer.deviceSp20,
              ),
            ),
            
            SizedBox(width: AppSizer.deviceWidth3),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: AppSizer.deviceSp16,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: AppSizer.deviceWidth1_5,
                          height: AppSizer.deviceWidth1_5,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: AppSizer.deviceHeight1),
                  
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: AppSizer.deviceSp14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: AppSizer.deviceHeight1),
                  
                  Text(
                    time,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withOpacity(0.7),
                      fontSize: AppSizer.deviceSp12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}