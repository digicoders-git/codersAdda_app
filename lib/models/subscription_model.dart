class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String duration;
  final List<String> features;
  final int deviceLimit;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    this.deviceLimit = 1,
    this.isPopular = false,
  });
}