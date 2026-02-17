// viewmodels/shorts_view_model.dart
import 'package:coders_adda_app/models/shorts_model.dart';
import 'package:flutter/material.dart';

class ShortsViewModel with ChangeNotifier {
  List<ShortVideo> _shorts = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  List<ShortVideo> get shorts => _shorts;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  ShortVideo? get currentShort => _shorts.isNotEmpty ? _shorts[_currentIndex] : null;

  // Mock data - in real app, this would come from API
  final List<ShortVideo> _demoShorts = [
    ShortVideo(
      id: '1',
      title: 'Flutter Animation Tips',
      creator: '@fluttermaster',
      thumbnail: 'https://picsum.photos/400/800?random=1',
      likes: 2500,
      comments: 356,
      description: 'Learn how to create smooth animations in Flutter with these pro tips! 🎬',
    ),
    ShortVideo(
      id: '2',
      title: 'State Management Simplified',
      creator: '@codewithfun',
      thumbnail: 'https://picsum.photos/400/800?random=2',
      likes: 1800,
      comments: 234,
      description: 'Understanding state management in Flutter made easy! 💡',
    ),
    ShortVideo(
      id: '3',
      title: 'UI Design Secrets',
      creator: '@designwizard',
      thumbnail: 'https://picsum.photos/400/800?random=3',
      likes: 3200,
      comments: 421,
      description: 'Create beautiful UIs that users will love! ✨',
    ),
    ShortVideo(
      id: '4',
      title: 'Firebase Integration',
      creator: '@backendpro',
      thumbnail: 'https://picsum.photos/400/800?random=4',
      likes: 1500,
      comments: 189,
      description: 'Connect your Flutter app with Firebase in minutes! 🔥',
    ),
  ];

  ShortsViewModel() {
    _loadShorts();
  }

  Future<void> _loadShorts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _shorts = _demoShorts;
    _isLoading = false;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void likeVideo(String videoId) {
    final index = _shorts.indexWhere((video) => video.id == videoId);
    if (index != -1) {
      final currentLikes = _shorts[index].likes;
      _shorts[index] = _shorts[index].copyWith(likes: currentLikes + 1);
      notifyListeners();
    }
  }

  void incrementComments(String videoId) {
    final index = _shorts.indexWhere((video) => video.id == videoId);
    if (index != -1) {
      final currentComments = _shorts[index].comments;
      _shorts[index] = _shorts[index].copyWith(comments: currentComments + 1);
      notifyListeners();
    }
  }

  Future<void> refreshShorts() async {
    await _loadShorts();
  }

  void shareVideo(String videoId) {
    // Implement share functionality
    debugPrint('Sharing video: $videoId');
  }

  void followCreator(String creator) {
    // Implement follow functionality
    debugPrint('Following creator: $creator');
  }
}