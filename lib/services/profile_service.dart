import 'dart:io';
import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiUrls.getProfile);
      return UserProfile.fromJson(response);
    } catch (e) {
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
