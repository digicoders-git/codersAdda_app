import 'package:coders_adda_app/models/home_model.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/models/coupon.dart';
import 'package:coders_adda_app/services/course_service.dart';
import 'package:coders_adda_app/services/slider_service.dart';
import 'package:coders_adda_app/services/coupon_service.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  final SliderService _sliderService = SliderService();
  final CourseService _courseService = CourseService();
  final CouponService _couponService = CouponService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BannerItem> _banners = [];
  List<BannerItem> get banners => _banners;

  List<Course> _coursesOnSale = [];
  List<Course> get coursesOnSale => _coursesOnSale;

  List<Course> _freeCourses = [];
  List<Course> get freeCourses => _freeCourses;

  List<Coupon> _activeCoupons = [];
  List<Coupon> get activeCoupons => _activeCoupons;

  Map<String, dynamic>? _recentProgress;
  Map<String, dynamic>? get recentProgress => _recentProgress;

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

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch everything in parallel for better performance
      await Future.wait([
        _fetchSliders(forceRefresh: forceRefresh),
        _fetchTrendingCourses(),
        _fetchFreeCourses(),
        _fetchCoupons(),
        _fetchRecentProgress(),
      ]);
    } catch (e) {
      print('Error in HomeViewModel fetchHomeData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSliders({bool forceRefresh = false}) async {
    try {
      _banners = await _sliderService.getSliders(forceRefresh: forceRefresh);
    } catch (e) {
      debugPrint('Error fetching sliders: $e');
    }
  }

  Future<void> _fetchTrendingCourses() async {
    try {
      _coursesOnSale = await _courseService.getCoursesByFilter(priceType: 'paid');
    } catch (e) {
      debugPrint('Error fetching trending courses: $e');
    }
  }

  Future<void> _fetchFreeCourses() async {
    try {
      _freeCourses = await _courseService.getCoursesByFilter(priceType: 'free');
    } catch (e) {
      debugPrint('Error fetching free courses: $e');
    }
  }

  Future<void> _fetchCoupons() async {
    try {
      _activeCoupons = await _couponService.getActiveCoupons();
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
    }
  }

  Future<void> _fetchRecentProgress() async {
    try {
      final response = await ApiClient().get(ApiUrls.getRecentProgress);
      if (response['success'] == true && response['data'] != null) {
        _recentProgress = response['data'];
      } else {
        _recentProgress = null;
      }
    } catch (e) {
      debugPrint('Error fetching recent progress: $e');
      _recentProgress = null;
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