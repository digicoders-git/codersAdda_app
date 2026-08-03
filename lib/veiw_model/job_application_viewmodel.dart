import 'package:flutter/material.dart';
import '../services/job_application_service.dart';

class JobApplicationViewModel extends ChangeNotifier {
  final JobApplicationService _service = JobApplicationService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _myApplications = [];
  List<dynamic> get myApplications => _myApplications;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> submitApplication(String jobId, Map<String, dynamic> formData, String? resumePath) async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _service.applyForJob(jobId, formData, resumePath);
      if (response['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll("Exception: ", ""));
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchMyApplications() async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _service.getMyApplications();
      if (response['success']) {
        _myApplications = response['data'] ?? [];
      } else {
        _setError(response['message']);
      }
    } catch (e) {
      _setError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> withdrawApplication(String applicationId) async {
    try {
      _setLoading(true);
      _setError(null);
      final response = await _service.withdrawApplication(applicationId);
      if (response['success']) {
        // Remove from list locally to avoid refetch
        _myApplications.removeWhere((app) => app['_id'] == applicationId);
        _setLoading(false);
        return true;
      } else {
        _setError(response['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll("Exception: ", ""));
      _setLoading(false);
      return false;
    }
  }
}
