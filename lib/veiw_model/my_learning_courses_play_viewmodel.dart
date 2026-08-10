import 'package:flutter/material.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';

class CoursePlayerViewModel extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  Course? _course;
  List<CurriculumTopic> _curriculumTopics = [];
  bool _isLoading = false;
  bool _isCurriculumLoading = false;
  String? _errorMessage;
  CourseLesson? _selectedLesson;
  String? _selectedTopicId;
  bool _isPlayingPromo = false;

  CoursePlayerViewModel(String courseId) {
    fetchCourseDetails(courseId);
  }

  // Getters
  Course? get course => _course;
  List<CurriculumTopic> get curriculumTopics => _curriculumTopics;
  bool get isLoading => _isLoading;
  bool get isCurriculumLoading => _isCurriculumLoading;
  String? get errorMessage => _errorMessage;
  CourseLesson? get selectedLesson => _selectedLesson;
  String? get selectedTopicId => _selectedTopicId;
  bool get isPlayingPromo => _isPlayingPromo;

  String? get currentVideoUrl {
    if (_isPlayingPromo) return _course?.promoVideoUrl;
    if (_selectedLesson != null && _selectedLesson!.videoUrl.isNotEmpty) {
      return _selectedLesson!.videoUrl;
    }
    if (_course?.promoVideoUrl != null && _course!.promoVideoUrl.isNotEmpty) {
      return _course!.promoVideoUrl;
    }
    return null;
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
      
      // Also fetch specialized curriculum
      _isCurriculumLoading = true;
      notifyListeners();
      _curriculumTopics = await _courseService.getCurriculumByCourse(courseId);
      _isCurriculumLoading = false;

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

      if ((_selectedLesson == null || _selectedLesson!.videoUrl.isEmpty) && 
          _course?.promoVideoUrl != null && _course!.promoVideoUrl.isNotEmpty) {
        _isPlayingPromo = true;
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

  Future<bool> submitReview(int rating, String comment, {String? studentName}) async {
    if (_course == null) return false;
    
    final data = <String, dynamic>{
      'rating': rating,
      'comment': comment,
    };
    if (studentName != null && studentName.isNotEmpty) {
      data['studentName'] = studentName;
    }
    
    final success = await _courseService.addCourseReview(_course!.id, data);
    if (success) {
      // Refresh course details in the background without blocking the return
      fetchCourseDetails(_course!.id);
    }
    return success;
  }
}



