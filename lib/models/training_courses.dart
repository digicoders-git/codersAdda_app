class TrainingCourse {
  final String id;
  final String title;
  final String type; 
  final String description;
  final String duration;
  final String location;
  final String imageUrl;
  final bool isFeatured;
  final String startDate;
  final String endDate;
  final String price;

  TrainingCourse({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.duration,
    required this.location,
    required this.imageUrl,
    this.isFeatured = false,
    required this.startDate,
    required this.endDate,
    required this.price,
  });
}