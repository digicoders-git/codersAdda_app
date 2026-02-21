import 'package:coders_adda_app/models/course_model.dart';

class SubscriptionPlan {
  final String id;
  final String planType;
  final String duration;
  final String planPricingType;
  final double price;
  final int freeJobs;
  final bool planStatus;
  final List<String> planBenefits;
  final List<Course> includedCourses;
  final List<dynamic> includedEbooks;
  final int totalStudents;
  final bool isInUse;

  SubscriptionPlan({
    required this.id,
    required this.planType,
    required this.duration,
    required this.planPricingType,
    required this.price,
    required this.freeJobs,
    required this.planStatus,
    required this.planBenefits,
    required this.includedCourses,
    required this.includedEbooks,
    this.totalStudents = 0,
    this.isInUse = false,
  });

  bool get isFree => planPricingType == 'free';

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      planType: json['planType'] ?? '',
      duration: json['duration'] ?? '',
      planPricingType: json['planPricingType'] ?? 'paid',
      price: (json['price'] ?? 0).toDouble(),
      freeJobs: json['freeJobs'] ?? 0,
      planStatus: json['planStatus'] ?? false,
      planBenefits: List<String>.from(json['planBenefits'] ?? []),
      includedCourses: (json['includedCourses'] as List<dynamic>?)
          ?.map((e) => Course.fromJson(e))
          .toList() ?? [],
      includedEbooks: json['includedEbooks'] ?? [],
      totalStudents: json['totalStudents'] ?? 0,
      isInUse: json['isInUse'] ?? false,
    );
  }
}