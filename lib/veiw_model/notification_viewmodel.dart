import 'dart:convert';
import 'package:coders_adda_app/models/notification_model.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> notifications = [];
  NotificationSettingsModel settings = NotificationSettingsModel();
  bool isLoading = false;
  int unreadCount = 0;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiUrls.getMyNotifications),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          notifications = (data['data'] as List)
              .map((e) => NotificationModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiUrls.getUnreadCount),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          unreadCount = data['count'];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await http.put(
        Uri.parse('${ApiUrls.markNotificationAsRead}/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        // Find how to clone or update isRead depending on implementation
        // For now, we will re-fetch
        fetchNotifications();
        fetchUnreadCount();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> fetchSettings() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiUrls.getNotificationSettings),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          settings = NotificationSettingsModel.fromJson(data['data']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching notification settings: $e');
    }
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    settings = newSettings;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) return;

      await http.put(
        Uri.parse(ApiUrls.updateNotificationSettings),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode(newSettings.toJson()),
      );
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
    }
  }
}
