import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class SliderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<BannerItem>> getSliders() async {
    try {
      final response = await _apiClient.get(ApiUrls.getSliders);
      print('Sliders API Response: $response');
      
      if (response is List) {
        return response.map((json) => BannerItem.fromJson(json)).toList();
      } else if (response is Map) {
        // Try all common keys for list data
        final possibleKeys = ['data', 'sliders', 'banners', 'slides', 'result'];
        for (var key in possibleKeys) {
          if (response.containsKey(key) && response[key] is List) {
            return (response[key] as List)
                .map((json) => BannerItem.fromJson(json))
                .toList();
          }
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching sliders: $e');
      rethrow;
    }
  }
}
