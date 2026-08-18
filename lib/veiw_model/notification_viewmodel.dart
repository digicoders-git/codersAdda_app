import 'dart:convert';
import 'package:coders_adda_app/models/notification_model.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> notifications = [];
  NotificationSettingsModel settings = NotificationSettingsModel();
  bool isLoading = false;
  int unreadCount = 0;

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> fetchNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('NotificationViewModel: No token found, skipping fetch');
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiUrls.getMyNotifications),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('fetchNotifications status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          notifications = (data['data'] as List)
              .map((e) => NotificationModel.fromJson(e))
              .toList();
          debugPrint('Fetched ${notifications.length} notifications');
        }
      } else {
        debugPrint('fetchNotifications error body: ${response.body}');
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
        if (data['success'] == true) {
          unreadCount = data['count'] ?? 0;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic UI update
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      if (unreadCount > 0) unreadCount--;
      notifyListeners();
    }

    try {
      final token = await _getToken();
      if (token == null) return;

      await http.put(
        Uri.parse('${ApiUrls.markNotificationAsRead}/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // We still fetch to ensure sync, but UI is already updated
      fetchNotifications();
      fetchUnreadCount();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await http.put(
        Uri.parse(ApiUrls.markAllAsRead),
        headers: {'Authorization': 'Bearer $token'},
      );

      fetchNotifications();
      fetchUnreadCount();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
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
        if (data['success'] == true) {
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
