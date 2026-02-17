import 'package:coders_adda_app/models/login_model.dart';
import 'package:coders_adda_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  AppUser? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get verificationId => _verificationId;
  bool get isLoggedIn => _currentUser != null;
  AppUser? get currentUser => _currentUser;

  final AuthService _authService = AuthService();

  Future<LoginResponse> requestOtp(String mobile, {String? referralCode}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.requestOtp(mobile, referralCode: referralCode);
      
      _isLoading = false;
      notifyListeners();

      if (response['success'] == true) {
        return LoginResponse(
          success: true,
          message: response['message'],
          verificationId: 'api_sent', // We use this to trigger OTP UI
        );
      } else {
        _errorMessage = response['message'] ?? 'Failed to send OTP';
        notifyListeners();
        return LoginResponse(success: false, message: _errorMessage);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return LoginResponse(success: false, message: e.toString());
    }
  }


  Future<LoginResponse> verifyOtp(String mobile, String otp, {String? referralCode}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.verifyOtp(mobile, otp, referralCode: referralCode);
      
      if (response['success'] == true) {
        // Map response to APP user model
        final userData = response['user'];
        _currentUser = AppUser(
          id: userData?['id'] ?? userData?['_id'] ?? 'user_id',
          phone: mobile,
        );
        
        _isLoading = false;
        notifyListeners();

        return LoginResponse(
          success: true,
          user: _currentUser,
          message: response['message'],
        );
      } else {
        _isLoading = false;
        _errorMessage = response['message'] ?? 'Verification failed';
        notifyListeners();
        return LoginResponse(success: false, message: _errorMessage);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return LoginResponse(success: false, message: e.toString());
    }
  }

  String _getMockPhone() {

    return '98765${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetVerification() {
    _verificationId = null;
    notifyListeners();
  }


  Future<void> signOut() async {
    await _authService.logout();
    _currentUser = null;
    _verificationId = null;
    _errorMessage = null;
    notifyListeners();
  }
}