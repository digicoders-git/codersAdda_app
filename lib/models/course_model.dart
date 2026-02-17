class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final double price;
  final String thumbnail;
  final String category;
  final String technology;
  final bool isFree;
  final double rating;
  final int totalStudents;
  final String duration;
  final int totalLessons;
  final DateTime createdAt;

  final List<String> whatYouWillLearn;
  final List<CourseModule> curriculum;
  final List<CourseFAQ> faqs;
  final List<CourseReview> reviews;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.price,
    required this.thumbnail,
    required this.category,
    required this.technology,
    required this.isFree,
    this.rating = 0.0,
    this.totalStudents = 0,
    required this.duration,
    this.totalLessons = 0,
    required this.createdAt,
    this.whatYouWillLearn = const [],
    this.curriculum = const [],
    this.faqs = const [],
    this.reviews = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    String _safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map && value.containsKey('url')) return value['url']?.toString() ?? '';
      if (value is Map && value.containsKey('name')) return value['name']?.toString() ?? '';
      if (value is Map && value.containsKey('fullName')) return value['fullName']?.toString() ?? '';
      return value.toString();
    }

    return Course(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: _safeString(json['instructor']),
      price: (json['price'] ?? 0).toDouble(),
      thumbnail: _safeString(json['thumbnail']),
      category: _safeString(json['category']),
      technology: json['technology'] ?? '',
      isFree: json['priceType'] == 'free' || (json['price'] ?? 0) == 0,
      rating: (json['totalRating'] ?? 0).toDouble(),
      totalStudents: json['totalStudents'] ?? 0,
      duration: json['duration'] ?? '0h',
      totalLessons: (json['curriculum'] is List)
          ? (json['curriculum'] as List).fold<int>(0, (sum, module) {
              final lessons = module['lessons'] as List?;
              return sum + (lessons?.length ?? 0);
            })
          : ((json['whatYouWillLearn'] is List) 
               ? (json['whatYouWillLearn'] as List).length 
               : 0),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      whatYouWillLearn: (json['whatYouWillLearn'] is List)
          ? List<String>.from(json['whatYouWillLearn'])
          : [],
      curriculum: (json['curriculum'] is List)
          ? (json['curriculum'] as List).map((i) => CourseModule.fromJson(i)).toList()
          : [],
      faqs: (json['faqs'] is List)
          ? (json['faqs'] as List).map((i) => CourseFAQ.fromJson(i)).toList()
          : [],
      reviews: (json['reviews'] is List)
          ? (json['reviews'] as List).map((i) => CourseReview.fromJson(i)).toList()
          : [],
    );
  }
}

class CourseFAQ {
  final String id;
  final String question;
  final String answer;

  CourseFAQ({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory CourseFAQ.fromJson(Map<String, dynamic> json) {
    return CourseFAQ(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class CourseReview {
  final String id;
  final String studentName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  CourseReview({
    required this.id,
    required this.studentName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['_id'] ?? '',
      studentName: json['studentName'] ?? 'Anonymous',
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class CourseCategory {
  final String id;
  final String name;
  final String technology;
  final int courseCount;
  final String icon;
  final bool isActive;

  CourseCategory({
    required this.id,
    required this.name,
    this.technology = 'All',
    this.courseCount = 0,
    this.icon = '📚',
    this.isActive = true,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    String rawName = json['name'] ?? '';
    String capitalizedName = rawName.isNotEmpty 
        ? '${rawName[0].toUpperCase()}${rawName.substring(1)}' 
        : '';
    return CourseCategory(
      id: json['_id'] ?? '',
      name: capitalizedName,
      technology: rawName,
      isActive: json['isActive'] ?? true,
    );
  }
}

class CourseModule {
  final String id;
  final String title;
  final String duration;
  final int lessonCount;
  final bool isLocked;
  final List<CourseLesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.duration,
    required this.lessonCount,
    this.isLocked = false,
    required this.lessons,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lessonsJson = json['lessons'] ?? [];
    final lessonsList = lessonsJson.map((l) => CourseLesson.fromJson(l)).toList();
    
    return CourseModule(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '0 min',
      lessonCount: lessonsList.length,
      isLocked: lessonsList.isNotEmpty ? lessonsList.every((l) => l.isLocked) : false,
      lessons: lessonsList,
    );
  }
}

class CourseLesson {
  final String id;
  final String title;
  final String duration;
  final String videoUrl;
  final String? pdfUrl;
  final String? thumbnailUrl;
  final bool isFree;
  final bool isLocked;
  final bool isCompleted;

  CourseLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    this.pdfUrl,
    this.thumbnailUrl,
    this.isFree = false,
    this.isLocked = false,
    this.isCompleted = false,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '0:00',
      videoUrl: json['videoUrl'] ?? '',
      pdfUrl: json['pdfUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      isFree: !(json['isLocked'] ?? false),
      isLocked: json['isLocked'] ?? false,
      isCompleted: false,
    );
  }
}
