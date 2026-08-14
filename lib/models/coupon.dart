import 'package:flutter/material.dart';

class Coupon {
  final String id;
  final String code;
  final int discountPercent;
  final int? maxDiscountAmount;
  final int minPurchaseAmount;
  final String description; // Might not exist on backend, keeping it for UI
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    this.maxDiscountAmount,
    this.minPurchaseAmount = 0,
    this.description = '',
    this.isActive = true,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      discountPercent: json['discountPercent'] ?? 0,
      maxDiscountAmount: json['maxDiscountAmount'],
      minPurchaseAmount: json['minPurchaseAmount'] ?? 0,
      description: 'Get ${json['discountPercent']}% off on your purchase!',
      isActive: json['isActive'] ?? true,
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final String description;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.description,
  });
}