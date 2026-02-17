import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

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
      print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP API
  Future<dynamic> verifyOtp(String mobile, String otp, {String? referralCode}) async {
    try {
      final Map<String, dynamic> body = {
        'mobile': mobile,
        'otp': otp,
      };
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

  // Logout
  Future<void> logout() async {
    await _apiClient.deleteToken();
  }
}
