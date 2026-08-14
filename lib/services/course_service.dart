import 'package:flutter/foundation.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class CourseService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> validateCoupon(String code, double amount) async {
    try {
      final body = {
        'code': code,
        'amount': amount,
      };
      final response = await _apiClient.post(ApiUrls.validateCoupon, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourseCategory>> getCategories({required String priceType}) async {
    try {
      final String url = '${ApiUrls.getCourseCategories}?priceType=$priceType';
      final response = await _apiClient.get(url);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => CourseCategory.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Course>> getCoursesByCategoryName(String categoryName) async {
    try {
      final String url = '${ApiUrls.getCoursesByCategoryName}?categoryName=$categoryName';
      final response = await _apiClient.get(url);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => Course.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching courses by category: $e');
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
      debugPrint('Error fetching $priceType courses: $e');
      return [];
    }
  }

  Future<List<Course>> getAllCoursesForSearch() async {
    try {
      final String url = '${ApiUrls.getCoursesByFilter}?isActive=true';
      final response = await _apiClient.get(url);
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => Course.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching courses for search: $e');
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
      debugPrint('Error fetching course details: $e');
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

  Future<Map<String, dynamic>> createOrder(String itemId, {String itemType = 'course', String? couponCode}) async {
    try {
      final body = {
        'itemType': itemType,
        'itemId': itemId,
      };
      if (couponCode != null && couponCode.isNotEmpty) {
        body['couponCode'] = couponCode;
      }
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

  Future<List<Map<String, dynamic>>> getActiveCoupons() async {
    try {
      final response = await _apiClient.get(ApiUrls.getActiveCoupons);
      if (response['success'] == true) {
        final List<dynamic> data = response['coupons'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching active coupons: $e');
      return [];
    }
  }

  Future<List<CurriculumTopic>> getCurriculumByCourse(String courseId) async {
    try {
      final String url = '${ApiUrls.getCurriculumByCourse}/$courseId';
      final response = await _apiClient.get(url);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => CurriculumTopic.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching curriculum: $e');
      return [];
    }
  }

  Future<List<CourseLecture>> getLecturesByTopic(String topicId) async {
    try {
      final String url = '${ApiUrls.getLectureByTopic}/$topicId';
      final response = await _apiClient.get(url);
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((item) => CourseLecture.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching lectures: $e');
      throw Exception('Parse error: $e');
    }
  }

  Future<bool> addCourseReview(String courseId, Map<String, dynamic> reviewData) async {
    try {
      final String url = '${ApiUrls.addCourseReview}/$courseId';
      final response = await _apiClient.post(url, reviewData);
      return response['success'] == true;
    } catch (e) {
      debugPrint('Error adding course review: $e');
      return false;
    }
  }
}
