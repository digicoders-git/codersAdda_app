import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class CourseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CourseCategory>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiUrls.getCourseCategories);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => CourseCategory.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Course>> getCoursesByFilter({required String priceType, bool isActive = true}) async {
    try {
      final String url = '${ApiUrls.getCoursesByFilter}?isActive=$isActive&priceType=$priceType';
      final response = await _apiClient.get(url);
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => Course.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching $priceType courses: $e');
      return [];
    }
  }

  Future<Course?> getCourseDetailsById(String courseId) async {
    try {
      final String url = '${ApiUrls.getCourseDetails}/$courseId';
      final response = await _apiClient.get(url);
      
      if (response['success'] == true) {
        return Course.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching course details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> enrollFreeCourse(String courseId) async {
    try {
      final body = {
        'itemType': 'course',
        'itemId': courseId,
      };
      final response = await _apiClient.post(ApiUrls.enrollFreeItem, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrder(String itemId, {String itemType = 'course'}) async {
    try {
      final body = {
        'itemType': itemType,
        'itemId': itemId,
      };
      final response = await _apiClient.post(ApiUrls.createOrder, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiClient.post(ApiUrls.verifyPayment, paymentData);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
