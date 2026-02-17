class PdfItem {
  final String id;
  final String title;
  final String description;
  final String fileSize;
  final String category;
  final bool isFree;
  final double price;
  final String downloadUrl;
  final String thumbnail;
  final int viewCount;
  final DateTime uploadedAt;
  final String author;

  PdfItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fileSize,
    required this.category,
    required this.isFree,
    this.price = 0,
    required this.downloadUrl,
    required this.thumbnail,
    this.viewCount = 0,
    required this.uploadedAt,
    required this.author,
  });
}

class PdfCategory {
  final String id;
  final String name;
  final int pdfCount;
  final String icon;
  final bool isActive;

  PdfCategory({
    required this.id,
    required this.name,
    this.pdfCount = 0,
    this.icon = '📚',
    this.isActive = true,
  });

  factory PdfCategory.fromJson(Map<String, dynamic> json) {
    return PdfCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      pdfCount: json['pdfCount'] ?? 0,
      icon: json['icon'] ?? '📚',
      isActive: json['isActive'] ?? true,
    );
  }
}