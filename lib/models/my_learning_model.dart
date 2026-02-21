class MyLearningCourse {
  final String id;
  final String title;
  final double progress;
  final String thumbnail;
  final String instructor;
  final DateTime purchaseDate;
  final bool isFree;
  final String technology;
  final String source;
  final List<CourseCurriculum> curriculum;

  MyLearningCourse({
    required this.id,
    required this.title,
    required this.progress,
    required this.thumbnail,
    required this.instructor,
    required this.purchaseDate,
    this.isFree = false,
    this.technology = '',
    this.source = '',
    this.curriculum = const [],
  });

  factory MyLearningCourse.fromJson(Map<String, dynamic> json) {
    return MyLearningCourse(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      progress: 0.0,
      thumbnail: json['thumbnail']?['url'] ?? '',
      instructor: json['instructor']?['_id'] ?? '',
      purchaseDate: DateTime.now(),
      isFree: json['priceType'] == 'free',
      technology: json['technology'] ?? '',
      source: json['source'] ?? '',
      curriculum: (json['curriculum'] as List<dynamic>?)
          ?.map((e) => CourseCurriculum.fromJson(e))
          .toList() ?? [],
    );
  }
}

class CourseCurriculum {
  final String id;
  final String topic;
  final List<CourseLecture> lectures;

  CourseCurriculum({
    required this.id,
    required this.topic,
    required this.lectures,
  });

  factory CourseCurriculum.fromJson(Map<String, dynamic> json) {
    return CourseCurriculum(
      id: json['_id'] ?? '',
      topic: json['topic'] ?? '',
      lectures: (json['lectures'] as List<dynamic>?)
          ?.map((e) => CourseLecture.fromJson(e))
          .toList() ?? [],
    );
  }
}

class CourseLecture {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final String thumbnailUrl;
  final String privacy;

  CourseLecture({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.privacy,
  });

  factory CourseLecture.fromJson(Map<String, dynamic> json) {
    return CourseLecture(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      videoUrl: json['video']?['url'] ?? '',
      thumbnailUrl: json['thumbnail']?['url'] ?? '',
      privacy: json['privacy'] ?? 'locked',
    );
  }
}

class MyLearningPdf {
  final String id;
  final String title;
  final String size;
  final bool isFree;
  final String downloadUrl;
  final String authorName;
  final String source;

  MyLearningPdf({
    required this.id,
    required this.title,
    required this.size,
    this.isFree = false,
    required this.downloadUrl,
    this.authorName = '',
    this.source = '',
  });

  factory MyLearningPdf.fromJson(Map<String, dynamic> json) {
    return MyLearningPdf(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      size: '0 MB',
      isFree: json['priceType'] == 'free',
      downloadUrl: json['pdf']?['url'] ?? '',
      authorName: json['authorName'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

class MyLibraryResponse {
  final List<MyLearningCourse> freeCourses;
  final List<MyLearningCourse> paidCourses;
  final List<MyLearningPdf> freePdfs;
  final List<MyLearningPdf> paidPdfs;

  MyLibraryResponse({
    required this.freeCourses,
    required this.paidCourses,
    required this.freePdfs,
    required this.paidPdfs,
  });

  factory MyLibraryResponse.fromJson(Map<String, dynamic> json) {
    final courses = json['courses'] ?? {};
    final ebooks = json['ebooks'] ?? {};

    return MyLibraryResponse(
      freeCourses: (courses['free'] as List<dynamic>?)
          ?.map((e) => MyLearningCourse.fromJson(e))
          .toList() ?? [],
      paidCourses: (courses['paid'] as List<dynamic>?)
          ?.map((e) => MyLearningCourse.fromJson(e))
          .toList() ?? [],
      freePdfs: (ebooks['free'] as List<dynamic>?)
          ?.map((e) => MyLearningPdf.fromJson(e))
          .toList() ?? [],
      paidPdfs: (ebooks['paid'] as List<dynamic>?)
          ?.map((e) => MyLearningPdf.fromJson(e))
          .toList() ?? [],
    );
  }

  factory MyLibraryResponse.empty() {
    return MyLibraryResponse(
      freeCourses: [],
      paidCourses: [],
      freePdfs: [],
      paidPdfs: [],
    );
  }
}