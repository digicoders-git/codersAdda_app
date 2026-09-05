import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiUrls.getProfile);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile', jsonEncode(response));
      } catch (_) {}
      return UserProfile.fromJson(response);
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('cached_profile');
        if (cached != null) {
          final decoded = jsonDecode(cached);
          return UserProfile.fromJson(decoded);
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(ApiUrls.updateProfile, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateProfileMultipart(Map<String, String> fields, {File? imageFile}) async {
    try {
      final response = await _apiClient.putMultipart(ApiUrls.updateProfile, fields, imageFile: imageFile);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
