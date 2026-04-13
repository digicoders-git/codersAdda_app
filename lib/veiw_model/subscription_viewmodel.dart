import 'package:coders_adda_app/models/subscription_model.dart';
import 'package:coders_adda_app/services/subscription_service.dart';
import 'package:flutter/material.dart';

class SubscriptionViewModel with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubscriptionPlan> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SubscriptionViewModel() {
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _subscriptionService.getSubscriptions();
    } catch (e) {
      debugPrint('Error in SubscriptionViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SubscriptionPlan?> getSubscriptionDetails(String subscriptionId) async {
    try {
      return await _subscriptionService.getSubscriptionDetails(subscriptionId);
    } catch (e) {
      debugPrint('Error fetching subscription details: $e');
      return null;
    }
  }
}