import '../models/payment_model.dart';
import 'api_urls.dart';
import 'api_client.dart';

class PaymentService {
  static final ApiClient _apiClient = ApiClient();

  static Future<List<PaymentHistoryItem>> getPaymentHistory() async {
    try {
      final response = await _apiClient.get(ApiUrls.paymentHistory);
      
      if (response['success'] == true) {
        final List payments = response['data'] ?? [];
        return payments.map((p) => PaymentHistoryItem.fromJson(p)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch payment history');
      }
    } catch (e) {
      throw Exception('Error fetching payment history: $e');
    }
  }
}
