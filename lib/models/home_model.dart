import 'package:coders_adda_app/models/course_model.dart';

class HomeModel {
  final List<BannerItem> banners;
  final List<Course> coursesOnSale;
  final List<Course> freeCourses;
  final List<PdfItem> freePdfs;
  final List<PdfItem> paidPdfs;
  final List<Job> jobs;

  HomeModel({
    required this.banners,
    required this.coursesOnSale,
    required this.freeCourses,
    required this.freePdfs,
    required this.paidPdfs,
    required this.jobs,
  });
}

class BannerItem {
  final String? id;
  final String title;
  final String subtitle;
  final String route;
  final String? imageUrl;

  BannerItem({
    this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    this.imageUrl,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    String? _safeString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map && value.containsKey('url')) return value['url']?.toString();
      if (value is Map && value.containsKey('path')) return value['path']?.toString();
      return value.toString();
    }

    return BannerItem(
      id: _safeString(json['_id'] ?? json['id']),
      title: _safeString(json['title']) ?? '',
      subtitle: _safeString(json['subtitle']) ?? '',
      route: _safeString(json['route']) ?? '',
      imageUrl: _safeString(json['image'] ?? json['imageUrl'] ?? json['banner']),
    );
  }
}


class PdfItem {
  final String id;
  final String title;
  final String size;
  final bool isFree;

  PdfItem({
    required this.id,
    required this.title,
    required this.size,
    this.isFree = false,
  });
}

class Job {
  final String id;
  final String title;
  final String company;
  final bool isPremium;

  Job({
    required this.id,
    required this.title,
    required this.company,
    this.isPremium = false,
  });
}