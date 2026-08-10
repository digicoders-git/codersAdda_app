import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/services/api_client.dart';

class FaqService {
  static Future<List<Map<String, dynamic>>> getFaqs({String platform = 'app'}) async {
    try {
      final response = await ApiClient().get('${ApiUrls.getFaqs}?platform=$platform');

      if (response != null && response['success'] == true) {
        final List<dynamic> faqsData = response['faqs'];
        return faqsData.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching FAQs: $e');
      return [];
    }
  }
}
