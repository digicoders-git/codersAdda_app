import 'package:coders_adda_app/models/coupon.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class CouponService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Coupon>> getActiveCoupons() async {
    try {
      final response = await _apiClient.get(ApiUrls.getActiveCoupons);
      
      if (response['success'] == true) {
        final List coupons = response['coupons'] ?? [];
        return coupons.map((c) => Coupon.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching active coupons: $e');
      return [];
    }
  }
}
