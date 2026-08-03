import 'package:coders_adda_app/models/job_model.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class JobsViewModel with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<JobDetail> _jobs = [];
  bool _isLoading = true;
  String? _error;
  
  // Pagination & Filters
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;
  
  int userTotalFreeJobsAllowed = 0;
  
  String searchQuery = '';
  String selectedJobCategory = '';
  String selectedLocation = '';
  String selectedExperience = '';
  String selectedWorkType = '';
  String selectedJobStatus = '';
  String selectedPriceType = '';
  double? minPrice;
  double? maxPrice;
  Set<String> selectedSkills = {};
  
  bool _isProcessingPayment = false;
  String? _purchasingJobId;

  // View Getters
  List<JobDetail> get allJobs => _jobs;
  bool get isLoading => _isLoading;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get purchasingJobId => _purchasingJobId;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  
  // For UI Compatibility (if still used)
  List<JobDetail> get filteredJobs => _jobs; 

  JobsViewModel() {
    fetchJobs();
  }

  Future<void> fetchJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _jobs = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build Query Parameters
      Map<String, String> queryParams = {
        'page': _currentPage.toString(),
        'limit': _limit.toString(),
      };

      if (searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
      if (selectedJobCategory.isNotEmpty && selectedJobCategory != 'All') queryParams['jobCategory'] = selectedJobCategory;
      if (selectedLocation.isNotEmpty) queryParams['location'] = selectedLocation;
      if (selectedExperience.isNotEmpty && selectedExperience != 'All Levels') queryParams['requiredExperience'] = selectedExperience;
      if (selectedWorkType.isNotEmpty && selectedWorkType != 'All Types') queryParams['workType'] = selectedWorkType;
      if (selectedJobStatus.isNotEmpty) queryParams['jobStatus'] = selectedJobStatus;
      if (selectedPriceType.isNotEmpty && selectedPriceType != 'All') queryParams['priceType'] = selectedPriceType;
      if (minPrice != null) queryParams['minPrice'] = minPrice!.toInt().toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice!.toInt().toString();

      // Construct URL with parameters
      String queryString = Uri(queryParameters: queryParams).query;
      String url = '${ApiUrls.getJobsV3}?$queryString';

      final response = await _apiClient.get(url);

      if (response['success'] == true) {
        List<dynamic> data = response['data'] ?? [];
        List<JobDetail> newJobs = data.map((item) => JobDetail.fromJson(item)).toList();
        
        if (refresh) {
          _jobs = newJobs;
        } else {
          _jobs.addAll(newJobs);
        }
        
        _totalPages = response['totalPages'] ?? 1;
        _currentPage = response['page'] ?? 1;
        userTotalFreeJobsAllowed = response['userTotalFreeJobsAllowed'] ?? 0;
      } else {
        _error = response['message'] ?? 'Failed to load jobs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter setters
  void setSearchQuery(String query) {
    searchQuery = query;
    fetchJobs(refresh: true);
  }

  void setSelectedJobCategory(String category) {
    selectedJobCategory = category;
    fetchJobs(refresh: true);
  }

  void setSelectedLocation(String location) {
    selectedLocation = location;
    fetchJobs(refresh: true);
  }

  void setSelectedExperience(String experience) {
    selectedExperience = experience;
    fetchJobs(refresh: true);
  }

  void setSelectedWorkType(String type) {
    selectedWorkType = type;
    fetchJobs(refresh: true);
  }

  void setSelectedPriceType(String type) {
    selectedPriceType = type;
    fetchJobs(refresh: true);
  }

  void setPriceRange(double? min, double? max) {
    minPrice = min;
    maxPrice = max;
    fetchJobs(refresh: true);
  }

  void clearAllFilters() {
    searchQuery = '';
    selectedJobCategory = '';
    selectedLocation = '';
    selectedExperience = '';
    selectedWorkType = '';
    selectedJobStatus = '';
    selectedPriceType = '';
    minPrice = null;
    maxPrice = null;
    selectedSkills.clear();
    fetchJobs(refresh: true);
  }

  void addSelectedSkill(String skill) {
    selectedSkills.add(skill);
    fetchJobs(refresh: true);
  }

  void removeSelectedSkill(String skill) {
    selectedSkills.remove(skill);
    fetchJobs(refresh: true);
  }

  // Pagination
  void loadNextPage() {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      fetchJobs();
    }
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        selectedJobCategory.isNotEmpty ||
        selectedLocation.isNotEmpty ||
        selectedExperience.isNotEmpty ||
        selectedWorkType.isNotEmpty ||
        selectedPriceType.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        selectedSkills.isNotEmpty;
  }

  // Keeping these getter stubs for UI compatibility if they were used for dropdown items
  List<String> get availableJobTypes => ['Work From Office', 'Work From Home', 'Hybrid'];
  List<String> get availableExperiences => ['Fresher', '1-2 Years', '3-5 Years', '5+ Years'];
  List<String> get availableJobCategories => ['Frontend', 'Backend', 'Full Stack', 'App Developer', 'UI/UX'];

  bool canApplyForJob(String jobId) {
    // This logic might need to be updated based on API response/user state
    return true; 
  }

  void applyForJob(String jobId) {
    // Logic for applying/unlocking
    notifyListeners();
  }

  // --- Payment & Unlocking Logic ---

  Future<void> handleJobUnlock(JobDetail job, ProfileViewModel profileViewModel, {required Function(String) onSuccess, required Function(String) onError, required Function(Map<String, dynamic>) onPaymentRequired, String? couponCode}) async {
    _isProcessingPayment = true;
    _purchasingJobId = job.id;
    notifyListeners();

    try {
      if (job.priceType == 'free') {
        // Case 1: Truly free job
        final response = await _apiClient.post(ApiUrls.enrollFreeItem, {
          'itemType': 'job',
          'itemId': job.id,
        });

        if (response['success'] == true) {
          onSuccess('Successfully enrolled for ${job.jobTitle}');
          _updateLocalJobLockedStatus(job.id, false);
          fetchJobs(refresh: true); // background refresh
          _isProcessingPayment = false;
          _purchasingJobId = null;
          notifyListeners();
        } else {
          _isProcessingPayment = false;
          _purchasingJobId = null;
          notifyListeners();
          onError(response['message'] ?? 'Enrollment failed');
        }
      } else {
        // Case 2: Paid or Locked job
        final freeUnlocks = profileViewModel.user?.freeJobUnlocksUsed ?? 0;

        if (freeUnlocks < userTotalFreeJobsAllowed) {
          // Use one of the free unlocks
          final response = await _apiClient.post(ApiUrls.enrollFreeItem, {
            'itemType': 'jobV3',
            'itemId': job.id,
          });

          if (response['success'] == true) {
            onSuccess('Job unlocked successfully using 1 free credit!');
            await profileViewModel.fetchUserProfile(); // Update credits
            _updateLocalJobLockedStatus(job.id, false);
            fetchJobs(refresh: true);
            _isProcessingPayment = false;
            _purchasingJobId = null;
            notifyListeners();
          } else {
            _isProcessingPayment = false;
            _purchasingJobId = null;
            notifyListeners();
            onError(response['message'] ?? 'Unlocking failed');
          }
        } else {
          // Payment required
          final orderResponse = await _apiClient.post(ApiUrls.createOrder, {
            'itemType': 'job',
            'itemId': job.id,
            if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
          });

          if (orderResponse['success'] == true) {
            _isProcessingPayment = false;
            notifyListeners();
            onPaymentRequired(orderResponse);
          } else {
            _isProcessingPayment = false;
            _purchasingJobId = null;
            notifyListeners();
            onError(orderResponse['message'] ?? 'Failed to create order');
          }
        }
      }
    } catch (e) {
      _isProcessingPayment = false;
      _purchasingJobId = null;
      notifyListeners();
      onError('Error: $e');
    }
  }

  void clearPaymentState() {
    _isProcessingPayment = false;
    _purchasingJobId = null;
    notifyListeners();
  }

  Future<void> verifyJobPayment(String jobId, PaymentSuccessResponse response, {required Function(String) onSuccess, required Function(String) onError}) async {
    _isProcessingPayment = true;
    notifyListeners();

    try {
      final verifyBody = {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
        'itemId': jobId,
        'itemType': 'job',
      };

      final result = await _apiClient.post(ApiUrls.verifyPayment, verifyBody);

      if (result['success'] == true) {
        onSuccess('Payment verified! Job unlocked successfully.');
        _updateLocalJobLockedStatus(jobId, false);
        fetchJobs(refresh: true);
      } else {
        onError(result['message'] ?? 'Payment verification failed');
      }
    } catch (e) {
      onError('Verification error: $e');
    } finally {
      _isProcessingPayment = false;
      _purchasingJobId = null;
      notifyListeners();
    }
  }

  void _updateLocalJobLockedStatus(String jobId, bool isLocked) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(locked: isLocked);
      notifyListeners();
    }
  }
}
