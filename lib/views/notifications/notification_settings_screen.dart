import 'package:coders_adda_app/models/notification_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_colors.dart';
import 'package:coders_adda_app/veiw_model/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchSettings();
    });
  }

  void _updateSetting(NotificationSettingsModel currentSettings, String key, bool value) {
    final map = currentSettings.toJson();
    map[key] = value;
    context.read<NotificationViewModel>().updateSettings(NotificationSettingsModel.fromJson(map));
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          final s = viewModel.settings;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Manage which notifications you receive',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildSwitch('Course Updates', s.courseUpdates, (v) => _updateSetting(s, 'courseUpdates', v)),
              _buildSwitch('Quizzes', s.quiz, (v) => _updateSetting(s, 'quiz', v)),
              _buildSwitch('Tests', s.test, (v) => _updateSetting(s, 'test', v)),
              _buildSwitch('Live Classes', s.liveClasses, (v) => _updateSetting(s, 'liveClasses', v)),
              _buildSwitch('Offers', s.offers, (v) => _updateSetting(s, 'offers', v)),
              _buildSwitch('Study Reminders', s.studyReminder, (v) => _updateSetting(s, 'studyReminder', v)),
              _buildSwitch('Assignments', s.assignment, (v) => _updateSetting(s, 'assignment', v)),
              _buildSwitch('Current Affairs', s.currentAffairs, (v) => _updateSetting(s, 'currentAffairs', v)),
              _buildSwitch('Payments', s.payments, (v) => _updateSetting(s, 'payments', v)),
              _buildSwitch('Announcements', s.announcements, (v) => _updateSetting(s, 'announcements', v)),
            ],
          );
        },
      ),
    );
  }
}
