class UserProfile {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String profilePicture;
  final String college;
  final String course;
  final String branch;
  final String semester;
  final List<String> technology;
  final List<String> skills;
  final String about;
  final String github;
  final String linkedin;
  final String portfolio;
  final DateTime createdAt;
  final int walletBalance;
  final int referralCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profilePicture,
    required this.college,
    required this.course,
    required this.branch,
    required this.semester,
    required this.technology,
    required this.skills,
    required this.about,
    required this.github,
    required this.linkedin,
    required this.portfolio,
    required this.createdAt,
    this.walletBalance = 0,
    this.referralCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return UserProfile(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      mobile: user['mobile'] ?? '',
      profilePicture: user['profilePicture']?['url'] ?? '',
      college: user['college'] ?? '',
      course: user['course'] ?? '',
      branch: user['branch'] ?? 'Computer Science',
      semester: user['semester'] ?? '',
      technology: List<String>.from(user['technology'] ?? []),
      skills: List<String>.from(user['skills'] ?? []),
      about: user['about'] ?? '',
      github: user['socialLinks']?['github'] ?? '',
      linkedin: user['socialLinks']?['linkedin'] ?? '',
      portfolio: user['socialLinks']?['portfolio'] ?? '',
      createdAt: DateTime.parse(user['createdAt'] ?? DateTime.now().toIso8601String()),
      walletBalance: user['walletBalance'] ?? 0,
      referralCount: user['referralCount'] ?? 0,
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final String icon;
  final DateTime achievedAt;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.achievedAt,
  });
}