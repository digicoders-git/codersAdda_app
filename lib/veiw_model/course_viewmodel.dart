import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:flutter/material.dart';

class CourseViewModel with ChangeNotifier {
  List<Course> _allCourses = [];
  List<CourseCategory> _categories = [];
  String _selectedTechnology = 'All';
  late TabController _tabController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final CourseService _courseService = CourseService();

  CourseViewModel() {
    fetchCategories();
    fetchCourses(); // Initial fetch for first tab (Free)
  }

  Future<void> fetchCategories() async {
    final fetchedCategories = await _courseService.getCategories();
    
    // Always start with 'All'
    _categories = [
      CourseCategory(
        id: 'all',
        name: 'All',
        technology: 'All',
        courseCount: 0,
        icon: '📚',
      ),
    ];

    if (fetchedCategories.isNotEmpty) {
      _categories.addAll(fetchedCategories);
    }
    notifyListeners();
  }

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final priceType = _selectedTabIndex == 0 ? 'free' : 'paid';
      _allCourses = await _courseService.getCoursesByFilter(priceType: priceType);
      
      // Update course count in categories based on fetched data
      _updateCategoryCounts();
    } catch (e) {
      print('Error in CourseViewModel fetchCourses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateCategoryCounts() {
    // Basic implementation: update counts for currently fetched list
    for (var i = 1; i < _categories.length; i++) {
      final tech = _categories[i].technology;
      final count = _allCourses.where((c) => 
        c.technology.toLowerCase() == tech.toLowerCase()).length;
      
      _categories[i] = CourseCategory(
        id: _categories[i].id,
        name: _categories[i].name,
        technology: tech,
        courseCount: count,
        icon: _categories[i].icon,
      );
    }
    
    // Update 'All' count
    _categories[0] = CourseCategory(
      id: 'all',
      name: 'All',
      technology: 'All',
      courseCount: _allCourses.length,
      icon: '📚',
    );
  }

  void initializeTabController(TickerProvider vsync) {
    _tabController = TabController(length: 2, vsync: vsync);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _selectedTabIndex = _tabController.index;
      _selectedTechnology = 'All'; // Reset filter when switching tabs
      fetchCourses();
    }
  }

  @override
  void dispose() {
    if (_tabController != null) _tabController.dispose();
    super.dispose();
  }

  int _selectedTabIndex = 0;

  List<Course> get allCourses => _allCourses;
  List<CourseCategory> get categories => _categories;
  String get selectedTechnology => _selectedTechnology;
  int get selectedTabIndex => _selectedTabIndex;

  List<Course> get filteredCourses {
    if (_selectedTechnology == 'All') {
      return _allCourses;
    }
    
    return _allCourses.where((course) => 
      course.technology.toLowerCase() == _selectedTechnology.toLowerCase()).toList();
  }

  void setSelectedTechnology(String technology) {
    _selectedTechnology = technology;
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      _selectedTechnology = 'All';
      fetchCourses();
    }
  }

  List<CourseModule> getCourseModules(String courseId) {

    return [
      CourseModule(
        id: '1',
        title: 'Introduction to Course',
        duration: '45 min',
        lessonCount: 3,
        isLocked: false,
        lessons: [
          CourseLesson( 
            id: '1',
            title: 'Welcome to the Course',
            duration: '10 min',
            videoUrl: 'https://example.com/video1.mp4',
            isFree: true,
          ),
          CourseLesson( 
            id: '2',
            title: 'Course Overview',
            duration: '15 min',
            videoUrl: 'https://example.com/video2.mp4',
            isFree: true,
          ),
          CourseLesson( 
            id: '3',
            title: 'Setup Development Environment',
            duration: '20 min',
            videoUrl: 'https://example.com/video3.mp4',
            isFree: false,
          ),
        ],
      ),
      CourseModule(
        id: '2',
        title: 'Core Concepts',
        duration: '2 hours',
        lessonCount: 5,
        isLocked: true,
        lessons: [
          CourseLesson( 
            id: '4',
            title: 'Understanding Widgets',
            duration: '25 min',
            videoUrl: 'https://example.com/video4.mp4',
            isFree: false,
          ),
          CourseLesson( 
            id: '5',
            title: 'State Management',
            duration: '30 min',
            videoUrl: 'https://example.com/video5.mp4',
            isFree: false,
          ),
        ],
      ),
    ];
  }
}