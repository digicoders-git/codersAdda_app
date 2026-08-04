import 'package:flutter/foundation.dart';
import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/home_cache_service.dart';

class SliderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BannerItem>> getSliders({bool forceRefresh = false}) async {
    try {
      // Fetch from API
      final response = await _apiClient.get('${ApiUrls.getSliders}?isActive=true');
      
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
      
      // Add default sliders if none exist from backend
      if (banners.isEmpty) {
        banners = [
          BannerItem(id: 'default1', title: '', subtitle: '', route: '', imageUrl: 'assets/images/default_slider_1.png'),
          BannerItem(id: 'default2', title: '', subtitle: '', route: '', imageUrl: 'assets/images/default_slider_2.jpg'),
          BannerItem(id: 'default3', title: '', subtitle: '', route: '', imageUrl: 'assets/images/default_slider_3.png'),
        ];
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
