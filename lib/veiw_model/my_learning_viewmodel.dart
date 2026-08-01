import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:coders_adda_app/services/my_library_service.dart';
import 'package:flutter/material.dart';

class MyLearningViewModel with ChangeNotifier {
  final MyLibraryService _libraryService = MyLibraryService();
  
  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<MyLearningCourse> _freeCourses = [];
  List<MyLearningCourse> _premiumCourses = [];
  List<MyLearningPdf> _freePdfs = [];
  List<MyLearningPdf> _premiumPdfs = [];

  // Getters
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MyLearningCourse> get freeCourses => _freeCourses;
  List<MyLearningCourse> get premiumCourses => _premiumCourses;
  List<MyLearningPdf> get freePdfs => _freePdfs;
  List<MyLearningPdf> get premiumPdfs => _premiumPdfs;

  MyLearningViewModel() {
    fetchMyLibrary();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchMyLibrary() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final response = await _libraryService.getMyLibrary();
      _freeCourses = response.freeCourses;
      _premiumCourses = response.paidCourses;
      _freePdfs = response.freePdfs;
      _premiumPdfs = response.paidPdfs;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error in MyLearningViewModel: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void updateCourseProgress(String courseId, double progress) {
    notifyListeners();
  }
}