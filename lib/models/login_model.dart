// models/login_model.dart
class AppUser {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;

  AppUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    String? photo;
    if (json['photoUrl'] != null) {
      photo = json['photoUrl'];
    } else if (json['picture'] != null) {
      photo = json['picture'];
    } else if (json['profilePicture'] is Map && json['profilePicture']['url'] != null) {
      photo = json['profilePicture']['url'];
    } else if (json['profilePicture'] is String) {
      photo = json['profilePicture'];
    }

    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: photo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }
}

class LoginResponse {
  final bool success;
  final bool requireMobile;
  final bool requireOtp;
  final bool waitingForApproval;
  final String? message;
  final String? mobile;
  final String? verificationId;
  final AppUser? user;

  LoginResponse({
    required this.success,
    this.requireMobile = false,
    this.requireOtp = false,
    this.waitingForApproval = false,
    this.message,
    this.mobile,
    this.verificationId,
    this.user,
  });
}

class User {
  String name;
  String email;

  User({required this.name, required this.email});
}
