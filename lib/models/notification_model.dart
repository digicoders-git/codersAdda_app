class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? image;
  final String? actionLink;
  final String priority;
  final String status;
  final String type;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    this.actionLink,
    required this.priority,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final notif = json['notification'] ?? {};
    return NotificationModel(
      id: json['_id'] ?? '',
      title: notif['title'] ?? '',
      body: notif['body'] ?? '',
      image: notif['image'],
      actionLink: notif['actionLink'],
      priority: notif['priority'] ?? 'Normal',
      status: notif['status'] ?? 'Sent',
      type: notif['type'] ?? 'General',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationSettingsModel {
  final bool courseUpdates;
  final bool quiz;
  final bool test;
  final bool liveClasses;
  final bool offers;
  final bool studyReminder;
  final bool assignment;
  final bool currentAffairs;
  final bool payments;
  final bool announcements;

  NotificationSettingsModel({
    this.courseUpdates = true,
    this.quiz = true,
    this.test = true,
    this.liveClasses = true,
    this.offers = true,
    this.studyReminder = true,
    this.assignment = true,
    this.currentAffairs = true,
    this.payments = true,
    this.announcements = true,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      courseUpdates: json['courseUpdates'] ?? true,
      quiz: json['quiz'] ?? true,
      test: json['test'] ?? true,
      liveClasses: json['liveClasses'] ?? true,
      offers: json['offers'] ?? true,
      studyReminder: json['studyReminder'] ?? true,
      assignment: json['assignment'] ?? true,
      currentAffairs: json['currentAffairs'] ?? true,
      payments: json['payments'] ?? true,
      announcements: json['announcements'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseUpdates': courseUpdates,
      'quiz': quiz,
      'test': test,
      'liveClasses': liveClasses,
      'offers': offers,
      'studyReminder': studyReminder,
      'assignment': assignment,
      'currentAffairs': currentAffairs,
      'payments': payments,
      'announcements': announcements,
    };
  }
}
