class MyLearningCourse {
  final String id;
  final String title;
  final double progress;
  final String thumbnail;
  final String instructor;
  final DateTime purchaseDate;
  final bool isFree;

  MyLearningCourse({
    required this.id,
    required this.title,
    required this.progress,
    required this.thumbnail,
    required this.instructor,
    required this.purchaseDate,
    this.isFree = false,
  });
}

class MyLearningPdf {
  final String id;
  final String title;
  final String size;
  final bool isFree;
  final String downloadUrl;

  MyLearningPdf({
    required this.id,
    required this.title,
    required this.size,
    this.isFree = false,
    required this.downloadUrl,
  });
}