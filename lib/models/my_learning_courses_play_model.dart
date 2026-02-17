class ReviewItem {
  final String name;
  final String initial;
  final int rating;
  final String comment;

  ReviewItem({
    required this.name,
    required this.initial,
    required this.rating,
    required this.comment,
  });
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class CourseSection {
  final String title;
  final List<String> topics;

  CourseSection({required this.title, required this.topics});
}

class CourseVideo {
  final double overallRating;
  final Map<int, int> ratingDistribution;
  final List<ReviewItem> reviews;
  final List<FAQItem> faqs;
  final List<CourseSection> courseSections;

  CourseVideo({
    required this.overallRating,
    required this.ratingDistribution,
    required this.reviews,
    required this.faqs,
    required this.courseSections,
  });
}