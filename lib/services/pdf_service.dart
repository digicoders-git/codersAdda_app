import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class PdfService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PdfCategory>> getEbookCategories() async {
    try {
      final response = await _apiClient.get(ApiUrls.getEbookCategories);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => PdfCategory.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching ebook categories: $e');
      return [];
    }
  }

  // Future<List<PdfItem>> getPdfsByCategory(String categoryId) async {
  //   // Will implement when ebook get API is provided
  //   return [];
  // }
}
