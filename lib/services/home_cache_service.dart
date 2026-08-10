import 'package:hive_flutter/hive_flutter.dart';

class HomeCacheService {
  static const String _boxName = 'home_cache';
  static const String _bannersKey = 'banners';
  static const String _bannersHashKey = 'banners_hash';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveBanners(List<Map<String, dynamic>> banners) async {
    final hash = banners.toString().hashCode;
    await _box.put(_bannersKey, banners);
    await _box.put(_bannersHashKey, hash);
  }

  static List<Map<String, dynamic>>? getCachedBanners() {
    final cached = _box.get(_bannersKey);
    if (cached != null && cached is List) {
      return List<Map<String, dynamic>>.from(
        cached.map((e) => Map<String, dynamic>.from(e))
      );
    }
    return null;
  }

  static bool hasNewBanners(List<Map<String, dynamic>> newBanners) {
    final cachedHash = _box.get(_bannersHashKey);
    final newHash = newBanners.toString().hashCode;
    return cachedHash != newHash;
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
