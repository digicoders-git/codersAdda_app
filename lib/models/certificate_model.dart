class CertificateModel {
  final String id;
  final String userId;
  final CourseInfo? course;
  final QuizInfo? quiz;
  final String certificateUrl;
  final String certificateId;
  final DateTime? issuedAt;

  CertificateModel({
    required this.id,
    required this.userId,
    this.course,
    this.quiz,
    required this.certificateUrl,
    required this.certificateId,
    this.issuedAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['_id'] ?? '',
      userId: json['user'] is String ? json['user'] : (json['user']?['_id'] ?? ''),
      course: json['course'] != null && json['course'] is Map ? CourseInfo.fromJson(json['course']) : null,
      quiz: json['quiz'] != null && json['quiz'] is Map ? QuizInfo.fromJson(json['quiz']) : null,
      certificateUrl: json['certificateUrl'] ?? '',
      certificateId: json['certificateId'] ?? '',
      issuedAt: json['issuedAt'] != null ? DateTime.tryParse(json['issuedAt']) : null,
    );
  }
}

class CourseInfo {
  final String id;
  final String title;
  final String thumbnail;

  CourseInfo({
    required this.id,
    required this.title,
    required this.thumbnail,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    String thumb = '';
    if (json['thumbnail'] is Map) {
      thumb = json['thumbnail']['url'] ?? '';
    } else if (json['thumbnail'] is String) {
      thumb = json['thumbnail'];
    }
    
    return CourseInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: thumb,
    );
  }
}

class QuizInfo {
  final String id;
  final String title;

  QuizInfo({
    required this.id,
    required this.title,
  });

  factory QuizInfo.fromJson(Map<String, dynamic> json) {
    return QuizInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
