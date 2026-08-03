import 'package:coders_adda_app/utils/app_colors/app_colors.dart';
import 'package:coders_adda_app/veiw_model/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_settings_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  void _handleNotificationTap(String id, String? actionLink) {
    context.read<NotificationViewModel>().markAsRead(id);
    if (actionLink != null && actionLink.isNotEmpty) {
      // Assuming Navigator.pushNamed is used for deep links
      Navigator.pushNamed(context, actionLink).catchError((_) {
        debugPrint('Route not found for $actionLink');
        return null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchNotifications(),
            child: ListView.builder(
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notif = viewModel.notifications[index];
                return InkWell(
                  onTap: () => _handleNotificationTap(notif.id, notif.actionLink),
                  child: Container(
                    color: notif.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: notif.isRead ? Colors.grey[300] : AppColors.primaryColor,
                          child: Icon(
                            Icons.notifications,
                            color: notif.isRead ? Colors.grey[600] : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (notif.image != null && notif.image!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      notif.image!,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                '${notif.createdAt.day}/${notif.createdAt.month}/${notif.createdAt.year}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
