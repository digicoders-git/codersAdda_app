import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('deviceId');
    if (deviceId == null || deviceId.isEmpty) {
      final random = Random();
      deviceId = '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(100000)}';
      await prefs.setString('deviceId', deviceId);
    }
    return deviceId;
  }

  // Request OTP API
  Future<dynamic> requestOtp(String mobile, {String? referralCode}) async {
    try {
      final Map<String, dynamic> body = {
        'mobile': mobile,
      };
      if (referralCode != null && referralCode.isNotEmpty) {
        body['referralCode'] = referralCode;
      }

      final response = await _apiClient.post(ApiUrls.requestOtp, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP API
  Future<dynamic> verifyOtp(String mobile, String otp, {String? referralCode, String? fcmToken}) async {
    try {
      final String deviceId = await getDeviceId();
      final Map<String, dynamic> body = {
        'mobile': mobile,
        'otp': otp,
        'deviceId': deviceId,
      };
      if (fcmToken != null && fcmToken.isNotEmpty) {
        body['fcmToken'] = fcmToken;
      }
      if (referralCode != null && referralCode.isNotEmpty) {
        body['referralCode'] = referralCode;
      }

      final response = await _apiClient.post(ApiUrls.verifyOtp, body);
      
      if (response['token'] != null) {
        await _apiClient.saveToken(response['token']);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Google Login API
  Future<dynamic> googleLogin(String? mobile, Map<String, dynamic> googleData, {String? referralCode}) async {
    try {
      final Map<String, dynamic> body = {
        'googleData': googleData,
      };
      if (mobile != null && mobile.isNotEmpty) {
        body['mobile'] = mobile;
      }
      if (referralCode != null && referralCode.isNotEmpty) {
        body['referralCode'] = referralCode;
      }

      final response = await _apiClient.post(ApiUrls.googleLogin, body);
      
      if (response['token'] != null) {
        await _apiClient.saveToken(response['token']);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update FCM Token
  Future<dynamic> updateFcmToken(String token) async {
    try {
      final response = await _apiClient.post(ApiUrls.updateFcmToken, {
        'fcmToken': token
      });
      return response;
    } catch (e) {
      print("Error updating FCM token: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiClient.deleteToken();
  }

  // Check login approval status
  Future<dynamic> checkLoginApprovalStatus(String mobile) async {
    try {
      final String deviceId = await getDeviceId();
      final response = await _apiClient.get('${ApiUrls.checkLoginApprovalStatus}?mobile=$mobile&deviceId=$deviceId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Approve Login
  Future<dynamic> approveLogin() async {
    try {
      final response = await _apiClient.post(ApiUrls.approveLogin, {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
