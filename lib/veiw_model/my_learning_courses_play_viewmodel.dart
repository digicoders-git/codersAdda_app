import 'package:flutter/material.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';

class CoursePlayerViewModel extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  Course? _course;
  bool _isLoading = false;
  String? _errorMessage;
  CourseLesson? _selectedLesson;
  String? _selectedTopicId;
  bool _isPlayingPromo = false;

  CoursePlayerViewModel(String courseId) {
    fetchCourseDetails(courseId);
  }

  // Getters
  Course? get course => _course;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CourseLesson? get selectedLesson => _selectedLesson;
  String? get selectedTopicId => _selectedTopicId;
  bool get isPlayingPromo => _isPlayingPromo;

  String? get currentVideoUrl {
    if (_isPlayingPromo) return _course?.promoVideoUrl;
    return _selectedLesson?.videoUrl;
  }

  void playPromoVideo() {
    _isPlayingPromo = true;
    _selectedLesson = null;
    notifyListeners();
  }

  // New Getters to maintain compatibility with existing UI if needed
  List<CourseReview> get reviews => _course?.reviews ?? [];
  List<CourseFAQ> get faqs => _course?.faqs ?? [];
  List<CourseModule> get courseSections => _course?.curriculum ?? [];

  Future<void> fetchCourseDetails(String courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _course = await _courseService.getCourseDetailsById(courseId);
      if (_course != null && _course!.curriculum.isNotEmpty) {
        // Automatically select the first lesson if available
        for (var module in _course!.curriculum) {
          if (module.lessons.isNotEmpty) {
            _selectedLesson = module.lessons.first;
            _selectedTopicId = module.id;
            break;
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load course details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLesson(CourseLesson lesson, String topicId) {
    _selectedLesson = lesson;
    _selectedTopicId = topicId;
    _isPlayingPromo = false;
    notifyListeners();
  }

  // If curriculum needs refreshing from separate APIs
  Future<void> refreshCurriculum() async {
    if (_course == null) return;
    try {
      final data = await _courseService.getCurriculumByCourse(_course!.id);
      // Update local course object if needed, though usually getCourseDetails handles it
    } catch (e) {
      print('Error refreshing curriculum: $e');
    }
  }
}



