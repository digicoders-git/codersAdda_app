import 'package:flutter/material.dart';

class Coupon {
  final String code;
  final int discount;
  final String description;
  final String type;

  Coupon({
    required this.code,
    required this.discount,
    required this.description,
    required this.type,
  });
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