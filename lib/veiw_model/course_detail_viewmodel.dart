import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:flutter/material.dart';

class CourseDetailViewModel with ChangeNotifier {
  final CourseService _courseService = CourseService();
  Course? _course;
  bool _isLoading = true;
  String? _errorMessage;

  CourseDetailViewModel(Course initialCourse) {
    _course = initialCourse;
    fetchCourseDetails();
  }

  Course? get course => _course;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCourseDetails() async {
    if (_course == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detailedCourse = await _courseService.getCourseDetailsById(_course!.id);
      if (detailedCourse != null) {
        _course = detailedCourse;
      } else {
        _errorMessage = "Failed to load detailed course content.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollInFreeCourse() async {
    if (_course == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _courseService.enrollFreeCourse(_course!.id);
      _isLoading = false;
      notifyListeners();

      if (response['success'] == true) {
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Enrollment failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
