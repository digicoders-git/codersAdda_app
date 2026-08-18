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
  final int freeJobUnlocksUsed;
  final int courseCount;
  final List<String> purchaseCourseIds;
  final List<String> purchaseEbookIds;
  final bool isAmbassador;
  final int completedCount;
  final int progressPercentage;
  final bool hasActiveSubscription;
  final String activeSubscriptionName;
  final List<String> subscriptionCourseIds;
  final List<Map<String, dynamic>> purchaseSubscriptions;
  final List<Map<String, dynamic>> purchaseJobs;

  int get calculatedProgressPercentage {
    int total = 11;
    int filled = 0;
    if (name.isNotEmpty) filled++;
    if (email.isNotEmpty) filled++;
    if (mobile.isNotEmpty) filled++;
    if (profilePicture.isNotEmpty) filled++;
    if (college.isNotEmpty) filled++;
    if (course.isNotEmpty) filled++;
    if (semester.isNotEmpty) filled++;
    if (about.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    if (technology.isNotEmpty) filled++;
    if (github.isNotEmpty || linkedin.isNotEmpty || portfolio.isNotEmpty) filled++;
    return ((filled / total) * 100).toInt();
  }

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
    this.freeJobUnlocksUsed = 0,
    this.courseCount = 0,
    this.purchaseCourseIds = const [],
    this.purchaseEbookIds = const [],
    this.isAmbassador = false,
    this.completedCount = 0,
    this.progressPercentage = 0,
    this.hasActiveSubscription = false,
    this.activeSubscriptionName = '',
    this.subscriptionCourseIds = const [],
    this.purchaseSubscriptions = const [],
    this.purchaseJobs = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    
    String extractedPic = '';
    if (user['profilePicture'] is Map && user['profilePicture']['url'] != null) {
      extractedPic = user['profilePicture']['url'];
    } else if (user['profilePicture'] is String) {
      extractedPic = user['profilePicture'];
    }
    if (extractedPic.isEmpty && user['picture'] is String) {
      extractedPic = user['picture'];
    }

    return UserProfile(
      id: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      mobile: user['mobile'] ?? '',
      profilePicture: extractedPic,
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
      freeJobUnlocksUsed: user['freeJobUnlocksUsed'] ?? 0,
      courseCount: (user['purchaseCourses'] as List?)?.length ?? 0,
      purchaseCourseIds: (user['purchaseCourses'] as List?)
          ?.map((c) => (c is Map) ? (c['_id']?.toString() ?? '') : c.toString())
          .where((id) => id.isNotEmpty)
          .toList() ?? [],
      purchaseEbookIds: (user['purchaseEbooks'] as List?)
          ?.map((e) => (e is Map) ? (e['_id']?.toString() ?? '') : e.toString())
          .where((id) => id.isNotEmpty)
          .toList() ?? [],
      isAmbassador: user['isAmbassador'] ?? false,
      completedCount: (json['user']?['courseCertificates'] as List?)?.length ?? 0,
      progressPercentage: (() {
        int total = (user['purchaseCourses'] as List?)?.length ?? 0;
        int completed = (json['user']?['courseCertificates'] as List?)?.length ?? 0;
        return total > 0 ? ((completed / (total > completed ? total : completed)) * 100).toInt().clamp(0, 100) : 0;
      })(),
      hasActiveSubscription: (() {
        final subs = user['purchaseSubscriptions'] as List?;
        if (subs == null || subs.isEmpty) return false;
        final now = DateTime.now();
        for (var sub in subs) {
          final status = sub['status'] ?? 'active';
          if (status == 'active') {
            final endDateStr = sub['endDate'];
            if (endDateStr == null) return true; // Assume lifetime if no end date
            final endDate = DateTime.tryParse(endDateStr);
            if (endDate != null && endDate.isAfter(now)) {
              return true;
            }
          }
        }
        return false;
      })(),
      activeSubscriptionName: (() {
        final subs = user['purchaseSubscriptions'] as List?;
        if (subs == null || subs.isEmpty) return '';
        final now = DateTime.now();
        for (var sub in subs) {
          final status = sub['status'] ?? 'active';
          if (status == 'active') {
            final endDateStr = sub['endDate'];
            final endDate = endDateStr != null ? DateTime.tryParse(endDateStr) : null;
            if (endDateStr == null || (endDate != null && endDate.isAfter(now))) {
              final subData = sub['subscription'];
              if (subData != null && subData is Map && subData['planType'] != null) {
                return subData['planType'].toString();
              }
              return 'Pro Member';
            }
          }
        }
        return '';
      })(),
      subscriptionCourseIds: (() {
        final subs = user['purchaseSubscriptions'] as List?;
        if (subs == null || subs.isEmpty) return <String>[];
        final now = DateTime.now();
        List<String> included = [];
        for (var sub in subs) {
          final status = sub['status'] ?? 'active';
          if (status == 'active') {
            final endDateStr = sub['endDate'];
            final endDate = endDateStr != null ? DateTime.tryParse(endDateStr) : null;
            if (endDateStr == null || (endDate != null && endDate.isAfter(now))) {
              final subData = sub['subscription'];
              if (subData != null && subData is Map && subData['includedCourses'] != null) {
                final courses = subData['includedCourses'] as List;
                included.addAll(courses.map((c) => (c is Map) ? c['_id']?.toString() ?? '' : c.toString()));
              }
            }
          }
        }
        return included;
      })(),
      purchaseSubscriptions: (() {
        final subs = user['purchaseSubscriptions'] as List?;
        if (subs == null) return <Map<String, dynamic>>[];
        return subs.whereType<Map<String, dynamic>>().toList();
      })(),
      purchaseJobs: (() {
        final jobs = user['purchaseJobs'] as List?;
        if (jobs == null) return <Map<String, dynamic>>[];
        return jobs.whereType<Map<String, dynamic>>().toList();
      })(),
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