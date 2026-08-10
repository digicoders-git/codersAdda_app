import 'package:coders_adda_app/services/api_urls.dart';

class PdfItem {
  final String id;
  final String title;
  final String description;
  final String fileSize;
  final String category;
  final String categoryId;
  final bool isFree;
  final String priceType;
  final double price;
  final String downloadUrl;
  final String thumbnail;
  final int viewCount;
  final DateTime uploadedAt;
  final String author;
  final bool isActive;

  PdfItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fileSize,
    required this.category,
    required this.categoryId,
    required this.isFree,
    required this.priceType,
    this.price = 0,
    required this.downloadUrl,
    required this.thumbnail,
    this.viewCount = 0,
    required this.uploadedAt,
    required this.author,
    required this.isActive,
  });

  factory PdfItem.fromJson(Map<String, dynamic> json) {
    return PdfItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileSize: json['pdf']?['fileSize'] ?? '0 KB',
      category: json['category']?['name'] ?? '',
      categoryId: json['category']?['_id'] ?? '',
      priceType: json['priceType'] ?? 'free',
      isFree: (json['priceType'] ?? 'free').toString().toLowerCase() == 'free',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      downloadUrl: ApiUrls.resolveMediaUrl(json['pdf']),
      thumbnail: ApiUrls.resolveMediaUrl(json['image']),
      viewCount: json['__v'] ?? 0, // Using __v as a placeholder for viewCount if not present
      uploadedAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      author: json['authorName'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}

class PdfCategory {
  final String id;
  final String name;
  final int ebookCount;
  final String icon;
  final bool isActive;

  PdfCategory({
    required this.id,
    required this.name,
    this.ebookCount = 0,
    this.icon = '📚',
    this.isActive = true,
  });

  factory PdfCategory.fromJson(Map<String, dynamic> json) {
    return PdfCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      ebookCount: json['ebookCount'] ?? 0,
      icon: json['icon'] ?? '📚',
      isActive: json['isActive'] ?? true,
    );
  }
}