import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedItem {
  final String id;
  final String title;
  final String localPath;
  final String type; // 'resource' or 'ebook'
  final String originalUrl;
  final String size;

  DownloadedItem({
    required this.id,
    required this.title,
    required this.localPath,
    required this.type,
    required this.originalUrl,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'localPath': localPath,
        'type': type,
        'originalUrl': originalUrl,
        'size': size,
      };

  factory DownloadedItem.fromJson(Map<String, dynamic> json) => DownloadedItem(
        id: json['id'],
        title: json['title'],
        localPath: json['localPath'],
        type: json['type'],
        originalUrl: json['originalUrl'],
        size: json['size'] ?? 'Unknown',
      );
}

class DownloadService {
  static const String _downloadsKey = 'downloaded_pdfs_list';
  final Dio _dio = Dio();

  Future<List<DownloadedItem>> getDownloadedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_downloadsKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => DownloadedItem.fromJson(e)).toList();
  }

  Future<void> _saveDownloadedItems(List<DownloadedItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_downloadsKey, data);
  }

  Future<void> addDownloadedItem(DownloadedItem item) async {
    final items = await getDownloadedItems();
    // Check if it already exists to prevent duplicates
    if (!items.any((element) => element.id == item.id)) {
      items.add(item);
      await _saveDownloadedItems(items);
    }
  }

  Future<bool> isDownloaded(String id) async {
    final items = await getDownloadedItems();
    final exists = items.any((element) => element.id == id);
    if (!exists) return false;

    // Optional: verify if file actually exists on device
    final item = items.firstWhere((element) => element.id == id);
    final file = File(item.localPath);
    if (!await file.exists()) {
      // Clean up metadata if file is missing
      await removeDownloadedItem(id);
      return false;
    }
    return true;
  }

  Future<void> removeDownloadedItem(String id) async {
    final items = await getDownloadedItems();
    final itemToRemove = items.cast<DownloadedItem?>().firstWhere((element) => element?.id == id, orElse: () => null);
    
    if (itemToRemove != null) {
      final file = File(itemToRemove.localPath);
      if (await file.exists()) {
        await file.delete();
      }
      items.removeWhere((element) => element.id == id);
      await _saveDownloadedItems(items);
    }
  }

  Future<String?> downloadPdf({
    required String id,
    required String title,
    required String url,
    required String type,
    String size = 'Unknown',
    Function(int count, int total)? onReceiveProgress,
  }) async {
    try {
      if (await isDownloaded(id)) {
        return 'Already downloaded';
      }

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      
      // Sanitize title for filename
      final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final fileName = '${id}_$sanitizedTitle.pdf';
      final String savePath = '${appDocDir.path}/$fileName';

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );

      final newItem = DownloadedItem(
        id: id,
        title: title,
        localPath: savePath,
        type: type,
        originalUrl: url,
        size: size,
      );

      final items = await getDownloadedItems();
      items.add(newItem);
      await _saveDownloadedItems(items);

      return savePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }
}
