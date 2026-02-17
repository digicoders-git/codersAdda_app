import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/services/slider_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  final SliderService _sliderService = SliderService();
  final CourseService _courseService = CourseService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BannerItem> _banners = [];
  List<BannerItem> get banners => _banners;

  List<Course> _coursesOnSale = [];
  List<Course> get coursesOnSale => _coursesOnSale;

  List<Course> _freeCourses = [];
  List<Course> get freeCourses => _freeCourses;

  final List<PdfItem> _freePdfs = [
    PdfItem(
      id: "1", 
      title: "Flutter Cheat Sheet", 
      size: "2.4 MB", 
      isFree: true,
    ),
  ];

  final List<PdfItem> _paidPdfs = [
    PdfItem(
      id: "2", 
      title: "Advanced Architecture", 
      size: "4.2 MB", 
      isFree: false,
    ),
  ];

  final List<Job> _jobs = [
    Job(id: "1", title: "Senior Flutter Developer", company: "TechCorp Inc."),
    Job(id: "2", title: "Android Engineer", company: "MobileFirst"),
  ];

  HomeViewModel() {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch everything in parallel for better performance
      await Future.wait([
        _fetchSliders(),
        _fetchTrendingCourses(),
        _fetchFreeCourses(),
      ]);
    } catch (e) {
      print('Error in HomeViewModel fetchHomeData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSliders() async {
    try {
      _banners = await _sliderService.getSliders();
    } catch (e) {
      print('Error fetching sliders: $e');
    }
  }

  Future<void> _fetchTrendingCourses() async {
    try {
      _coursesOnSale = await _courseService.getCoursesByFilter(priceType: 'paid');
    } catch (e) {
      print('Error fetching trending courses: $e');
    }
  }

  Future<void> _fetchFreeCourses() async {
    try {
      _freeCourses = await _courseService.getCoursesByFilter(priceType: 'free');
    } catch (e) {
      print('Error fetching free courses: $e');
    }
  }

  HomeModel get homeData => HomeModel(
    banners: _banners,
    coursesOnSale: _coursesOnSale,
    freeCourses: _freeCourses,
    freePdfs: _freePdfs,
    paidPdfs: _paidPdfs,
    jobs: _jobs,
  );

  void navigateToCategory(String category) {
    // Navigation logic
  }

  void navigateToCourse(String courseId) {
    // Navigation logic
  }
}