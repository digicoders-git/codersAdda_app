import 'package:hive_flutter/hive_flutter.dart';

class OfflinePdfModel {
  final String id;
  final String title;
  final String localPath;
  final String category;
  final String thumbnail;
  final DateTime downloadedAt;

  OfflinePdfModel({
    required this.id,
    required this.title,
    required this.localPath,
    required this.category,
    required this.thumbnail,
    required this.downloadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'localPath': localPath,
      'category': category,
      'thumbnail': thumbnail,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }

  factory OfflinePdfModel.fromMap(Map<dynamic, dynamic> map) {
    return OfflinePdfModel(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown PDF',
      localPath: map['localPath'] ?? '',
      category: map['category'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      downloadedAt: map['downloadedAt'] != null 
          ? DateTime.parse(map['downloadedAt']) 
          : DateTime.now(),
    );
  }
}

class OfflinePdfService {
  static const String _boxName = 'offline_pdfs_box';
  
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }
  
  static Box get _box => Hive.box(_boxName);

  static Future<void> savePdf(OfflinePdfModel pdf) async {
    await _box.put(pdf.id, pdf.toMap());
  }

  static List<OfflinePdfModel> getDownloadedPdfs() {
    final values = _box.values.toList();
    return values.map((e) => OfflinePdfModel.fromMap(e as Map<dynamic, dynamic>)).toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
  }

  static bool isPdfDownloaded(String id) {
    return _box.containsKey(id);
  }

  static OfflinePdfModel? getPdf(String id) {
    final data = _box.get(id);
    if (data != null) {
      return OfflinePdfModel.fromMap(data as Map<dynamic, dynamic>);
    }
    return null;
  }

  static Future<void> removePdf(String id) async {
    await _box.delete(id);
  }
}
