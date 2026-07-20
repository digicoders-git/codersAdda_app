import 'package:flutter/foundation.dart';
import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/home_cache_service.dart';

class SliderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BannerItem>> getSliders() async {
    try {
      // Check cache first
      final cached = HomeCacheService.getCachedBanners();
      if (cached != null && cached.isNotEmpty) {
        return cached.map((json) => BannerItem.fromJson(json)).toList();
      }

      // Fetch from API
      final response = await _apiClient.get(ApiUrls.getSliders);
      
      List<BannerItem> banners = [];
      List<Map<String, dynamic>> rawData = [];

      if (response is List) {
        rawData = List<Map<String, dynamic>>.from(response);
        banners = rawData.map((json) => BannerItem.fromJson(json)).toList();
      } else if (response is Map) {
        final possibleKeys = ['data', 'sliders', 'banners', 'slides', 'result'];
        for (var key in possibleKeys) {
          if (response.containsKey(key) && response[key] is List) {
            rawData = List<Map<String, dynamic>>.from(response[key]);
            banners = rawData.map((json) => BannerItem.fromJson(json)).toList();
            break;
          }
        }
      }

      // Save to cache if new data
      if (rawData.isNotEmpty && HomeCacheService.hasNewBanners(rawData)) {
        await HomeCacheService.saveBanners(rawData);
      }
      
      return banners;
    } catch (e) {
      debugPrint('Error fetching sliders: $e');
      final cached = HomeCacheService.getCachedBanners();
      if (cached != null) {
        return cached.map((json) => BannerItem.fromJson(json)).toList();
      }
      rethrow;
    }
  }
}
