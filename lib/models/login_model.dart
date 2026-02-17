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
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: json['photoUrl'],
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
  final String? message;
  final String? verificationId;
  final AppUser? user;

  LoginResponse({
    required this.success,
    this.message,
    this.verificationId,
    this.user,
  });
}

class User {
  String name;
  String email;

  User({required this.name, required this.email});
}
