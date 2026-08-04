import 'package:coders_adda_app/models/pdf_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class PdfService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PdfCategory>> getEbookCategories({required String priceType}) async {
    try {
      final response = await _apiClient.get('${ApiUrls.getEbookCategories}?priceType=$priceType');
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

  Future<List<PdfItem>> getEbooksByCategoryName(String categoryName) async {
    try {
      final String url = '${ApiUrls.getEbooksByCategoryName}?categoryName=$categoryName';
      final response = await _apiClient.get(url);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => PdfItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching ebooks by category: $e');
      return [];
    }
  }

  Future<List<PdfItem>> getEbooks({bool? isActive, String? priceType, String? categoryId}) async {
    try {
      String url = ApiUrls.getEbooks;
      List<String> params = [];
      if (isActive != null) params.add('isActive=$isActive');
      if (priceType != null) params.add('priceType=$priceType');
      if (categoryId != null) params.add('category=$categoryId');
      
      if (params.isNotEmpty) {
        url += '?' + params.join('&');
      }

      final response = await _apiClient.get(url);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => PdfItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching ebooks: $e');
      return [];
    }
  }

  Future<PdfItem?> getEbookDetails(String ebookId) async {
    try {
      final response = await _apiClient.get('${ApiUrls.getEbookDetails}/$ebookId');
      if (response['success'] == true) {
        return PdfItem.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching ebook details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> enrollFreeEbook(String ebookId) async {
    try {
      final body = {
        'itemType': 'ebook',
        'itemId': ebookId,
      };
      final response = await _apiClient.post(ApiUrls.enrollFreeItem, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
