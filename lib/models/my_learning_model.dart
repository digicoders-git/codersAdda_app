import 'package:coders_adda_app/services/api_urls.dart';

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
  final double rating;
  final String duration;
  final int totalVideos;

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
    this.rating = 0.0,
    this.duration = '0h',
    this.totalVideos = 0,
  });

  factory MyLearningCourse.fromJson(Map<String, dynamic> json) {
    String _safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        if (value.containsKey('name')) return value['name']?.toString() ?? '';
        if (value.containsKey('fullName')) return value['fullName']?.toString() ?? '';
      }
      return value.toString();
    }

    return MyLearningCourse(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      progress: 0.0,
      thumbnail: json['thumbnail']?['url'] ?? '',
      instructor: _safeString(json['instructor']),
      purchaseDate: DateTime.now(),
      isFree: json['priceType'] == 'free',
      technology: json['technology'] ?? '',
      source: json['source'] ?? '',
      curriculum: (json['curriculum'] as List<dynamic>?)
          ?.map((e) => CourseCurriculum.fromJson(e))
          .toList() ?? [],
      rating: (() {
        if (json['reviews'] is List && (json['reviews'] as List).isNotEmpty) {
          final reviews = json['reviews'] as List;
          double totalRating = 0;
          for (var r in reviews) {
            totalRating += (r['rating'] ?? 0).toDouble();
          }
          return totalRating / reviews.length;
        }
        return (json['totalRating'] ?? 0).toDouble();
      })(),
      duration: json['duration'] ?? '0h',
      totalVideos: (json['curriculum'] as List<dynamic>?)?.fold<int>(0, (sum, module) {
          final lessons = module['lessons'] as List?;
          return sum + (lessons?.length ?? 0);
        }) ?? 0,
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
  final String category;
  final String thumbnail;
  final double rating;
  final int views;
  final int totalReviews;

  MyLearningPdf({
    required this.id,
    required this.title,
    required this.size,
    this.isFree = false,
    required this.downloadUrl,
    this.authorName = '',
    this.source = '',
    this.category = '',
    this.thumbnail = '',
    this.rating = 0.0,
    this.views = 0,
    this.totalReviews = 0,
  });

  factory MyLearningPdf.fromJson(Map<String, dynamic> json) {
    return MyLearningPdf(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      size: json['pdf']?['fileSize'] ?? '0 MB',
      isFree: json['priceType'] == 'free',
      downloadUrl: ApiUrls.resolveMediaUrl(json['pdf']),
      authorName: json['authorName'] ?? '',
      source: json['source'] ?? '',
      category: json['category'] is String ? json['category'] : (json['category']?['title'] ?? ''),
      thumbnail: json['thumbnail'] is String ? json['thumbnail'] : (json['thumbnail']?['url'] ?? ''),
      rating: (json['rating'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}

class MyLearningJob {
  final String id;
  final String jobTitle;
  final String companyName;
  final String location;
  final String salaryPackage;
  final String requiredExperience;
  final String workType;
  final bool isActive;

  MyLearningJob({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.salaryPackage,
    required this.requiredExperience,
    required this.workType,
    required this.isActive,
  });

  factory MyLearningJob.fromJson(Map<String, dynamic> json) {
    return MyLearningJob(
      id: json['_id'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      location: json['location'] ?? '',
      salaryPackage: json['salaryPackage']?.toString() ?? '',
      requiredExperience: json['requiredExperience'] ?? '',
      workType: json['workType'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}

class MyLibraryResponse {
  final List<MyLearningCourse> freeCourses;
  final List<MyLearningCourse> paidCourses;
  final List<MyLearningPdf> freePdfs;
  final List<MyLearningPdf> paidPdfs;
  final List<MyLearningJob> jobs;

  MyLibraryResponse({
    required this.freeCourses,
    required this.paidCourses,
    required this.freePdfs,
    required this.paidPdfs,
    required this.jobs,
  });

  factory MyLibraryResponse.fromJson(Map<String, dynamic> json) {
    final courses = json['courses'] ?? {};
    final ebooks = json['ebooks'] ?? {};
    final jobsList = json['jobs'] ?? [];

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
      jobs: (jobsList as List<dynamic>)
          .map((e) => MyLearningJob.fromJson(e))
          .toList(),
    );
  }

  factory MyLibraryResponse.empty() {
    return MyLibraryResponse(
      freeCourses: [],
      paidCourses: [],
      freePdfs: [],
      paidPdfs: [],
      jobs: [],
    );
  }
}