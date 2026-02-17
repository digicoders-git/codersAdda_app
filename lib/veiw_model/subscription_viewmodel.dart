import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:flutter/material.dart';

class SubscriptionViewModel with ChangeNotifier {
  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: "1",
      name: "Mobile",
      price: 99,
      duration: "1 Month",
      features: [
        "Access on 1 device",
        "All free courses",
        "Basic PDF access",
        "Standard support",
      ],
      deviceLimit: 1,
      isPopular: false,
    ),
    SubscriptionPlan(
      id: "2",
      name: "Super",
      price: 499,
      duration: "1 Year",
      features: [
        "Access on 4 devices",
        "All premium courses",
        "All PDF downloads",
        "Priority support",
        "Ad-free experience",
        "Job opportunities",
      ],
      deviceLimit: 4,
      isPopular: true,
    ),
    SubscriptionPlan(
      id: "3",
      name: "Premium",
      price: 299,
      duration: "6 Months",
      features: [
        "Access on 2 devices",
        "All premium courses",
        "PDF downloads",
        "Priority support",
        "Ad-free experience",
      ],
      deviceLimit: 2,
      isPopular: false,
    ),
  ];

  List<SubscriptionPlan> get plans => _plans;
}