import 'package:coders_adda_app/models/shorts_model.dart';
import 'package:coders_adda_app/services/shorts_services.dart';
import 'package:flutter/material.dart';

class ShortsViewModel with ChangeNotifier {
  final ShortsService _shortsService = ShortsService();
  
  List<ShortVideo> _shorts = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  Map<String, bool> _likedStatus = {}; // shortId -> isLiked
  Map<String, List<ShortComment>> _comments = {}; // shortId -> comments

  List<ShortVideo> get shorts => _shorts;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  ShortVideo? get currentShort => _shorts.isNotEmpty && _currentIndex < _shorts.length ? _shorts[_currentIndex] : null;

  ShortsViewModel();

  Future<void> fetchShorts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _shorts = await _shortsService.getActiveShorts();
      // Initialize likes check for the first few shorts if needed, 
      // but usually better to do it as they appear.
    } catch (e) {
      print('Error in ViewModel fetching shorts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      checkCurrentShortLikedStatus();
      notifyListeners();
    }
  }

  bool isLiked(String shortId) => _likedStatus[shortId] ?? false;

  Future<void> checkCurrentShortLikedStatus() async {
    final short = currentShort;
    if (short == null) return;
    
    if (!_likedStatus.containsKey(short.id)) {
      final liked = await _shortsService.checkIsLiked(short.id);
      _likedStatus[short.id] = liked;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String shortId) async {
    final originalStatus = _likedStatus[shortId] ?? false;
    
    // Optimistic UI update
    _likedStatus[shortId] = !originalStatus;
    
    // Update local count
    final index = _shorts.indexWhere((s) => s.id == shortId);
    if (index != -1) {
      final currentLikes = _shorts[index].totalLikes;
      _shorts[index] = _shorts[index].copyWith(
        totalLikes: !originalStatus ? currentLikes + 1 : currentLikes - 1,
      );
    }
    notifyListeners();

    try {
      await _shortsService.toggleLike(shortId);
    } catch (e) {
      // Revert on error
      _likedStatus[shortId] = originalStatus;
      if (index != -1) {
        final currentLikes = _shorts[index].totalLikes;
        _shorts[index] = _shorts[index].copyWith(
          totalLikes: originalStatus ? currentLikes + 1 : currentLikes - 1,
        );
      }
      notifyListeners();
    }
  }

  List<ShortComment> getComments(String shortId) => _comments[shortId] ?? [];

  Future<void> fetchComments(String shortId) async {
    try {
      final fetchedComments = await _shortsService.getShortComments(shortId);
      _comments[shortId] = fetchedComments;
      
      // Sync comment count just in case
      final index = _shorts.indexWhere((s) => s.id == shortId);
      if (index != -1) {
        _shorts[index] = _shorts[index].copyWith(totalComments: fetchedComments.length);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching comments in ViewModel: $e');
    }
  }

  Future<void> addComment(String shortId, String text) async {
    try {
      final response = await _shortsService.addComment(shortId, text);
      if (response['success'] == true) {
        await fetchComments(shortId); // Refresh comments
      }
    } catch (e) {
      print('Error adding comment in ViewModel: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String shortId, String commentId) async {
    try {
      final response = await _shortsService.deleteComment(commentId);
      if (response['success'] == true) {
        _comments[shortId]?.removeWhere((c) => c.id == commentId);
        
        final index = _shorts.indexWhere((s) => s.id == shortId);
        if (index != -1) {
          final count = _shorts[index].totalComments;
          _shorts[index] = _shorts[index].copyWith(totalComments: count - 1);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting comment in ViewModel: $e');
      rethrow;
    }
  }
}