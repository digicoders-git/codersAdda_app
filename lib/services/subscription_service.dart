import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<SubscriptionPlan>> getSubscriptions() async {
    try {
      final response = await _apiClient.get(ApiUrls.getSubscriptions);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => SubscriptionPlan.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return [];
    }
  }

  Future<SubscriptionPlan?> getSubscriptionDetails(String subscriptionId) async {
    try {
      final response = await _apiClient.get('${ApiUrls.getSubscriptionDetails}/$subscriptionId');
      if (response['success'] == true) {
        return SubscriptionPlan.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching subscription details: $e');
      return null;
    }
  }
}
