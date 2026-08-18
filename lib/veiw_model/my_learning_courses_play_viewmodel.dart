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
  bool _isExplicitlyPlayingPromo = false;

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
  
  bool get isPlayingPromo {
    if (_isExplicitlyPlayingPromo) return true;
    if (_selectedLesson != null && _selectedLesson!.videoUrl.isNotEmpty) {
      return false;
    }
    if (_course?.promoVideoUrl != null && _course!.promoVideoUrl.isNotEmpty) {
      return true;
    }
    return false;
  }

  String? get currentVideoUrl {
    if (_isExplicitlyPlayingPromo) return _course?.promoVideoUrl;
    if (_selectedLesson != null && _selectedLesson!.videoUrl.isNotEmpty) {
      return _selectedLesson!.videoUrl;
    }
    if (_course?.promoVideoUrl != null && _course!.promoVideoUrl.isNotEmpty) {
      return _course!.promoVideoUrl;
    }
    return null;
  }

  void playPromoVideo() {
    _isExplicitlyPlayingPromo = true;
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
        _isExplicitlyPlayingPromo = true;
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
    _isExplicitlyPlayingPromo = false;
    notifyListeners();
  }

  bool get hasPrevLecture {
    if (_course == null || _course!.curriculum.isEmpty || _selectedLesson == null) return false;
    
    final curriculum = _course!.curriculum;
    
    // Find current module and lesson index
    for (int i = 0; i < curriculum.length; i++) {
      final module = curriculum[i];
      final lessonIndex = module.lessons.indexWhere((l) => l.id == _selectedLesson!.id);
      
      if (lessonIndex != -1) {
        if (lessonIndex - 1 >= 0) {
          return true;
        }
        for (int j = i - 1; j >= 0; j--) {
          if (curriculum[j].lessons.isNotEmpty) {
            return true;
          }
        }
        break;
      }
    }
    return false;
  }

  bool get hasNextLecture {
    if (_course == null || _course!.curriculum.isEmpty || _selectedLesson == null) return false;
    
    final curriculum = _course!.curriculum;
    
    // Find current module and lesson index
    for (int i = 0; i < curriculum.length; i++) {
      final module = curriculum[i];
      final lessonIndex = module.lessons.indexWhere((l) => l.id == _selectedLesson!.id);
      
      if (lessonIndex != -1) {
        // If there is a next lesson in the current module
        if (lessonIndex + 1 < module.lessons.length) {
          return true;
        }
        // Otherwise check next modules for lessons
        for (int j = i + 1; j < curriculum.length; j++) {
          if (curriculum[j].lessons.isNotEmpty) {
            return true;
          }
        }
        break;
      }
    }
    return false;
  }

  void playPrevLecture() {
    if (_course == null || _course!.curriculum.isEmpty || _selectedLesson == null) return;
    
    final curriculum = _course!.curriculum;
    
    for (int i = 0; i < curriculum.length; i++) {
      final module = curriculum[i];
      final lessonIndex = module.lessons.indexWhere((l) => l.id == _selectedLesson!.id);
      
      if (lessonIndex != -1) {
        if (lessonIndex - 1 >= 0) {
          selectLesson(module.lessons[lessonIndex - 1], module.id);
          return;
        }
        for (int j = i - 1; j >= 0; j--) {
          if (curriculum[j].lessons.isNotEmpty) {
            selectLesson(curriculum[j].lessons.last, curriculum[j].id);
            return;
          }
        }
        break;
      }
    }
  }

  void playNextLecture() {
    if (_course == null || _course!.curriculum.isEmpty || _selectedLesson == null) return;
    
    final curriculum = _course!.curriculum;
    
    for (int i = 0; i < curriculum.length; i++) {
      final module = curriculum[i];
      final lessonIndex = module.lessons.indexWhere((l) => l.id == _selectedLesson!.id);
      
      if (lessonIndex != -1) {
        // Play next lesson in current module
        if (lessonIndex + 1 < module.lessons.length) {
          selectLesson(module.lessons[lessonIndex + 1], module.id);
          return;
        }
        // Play first lesson in next modules
        for (int j = i + 1; j < curriculum.length; j++) {
          if (curriculum[j].lessons.isNotEmpty) {
            selectLesson(curriculum[j].lessons.first, curriculum[j].id);
            return;
          }
        }
        break;
      }
    }
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



