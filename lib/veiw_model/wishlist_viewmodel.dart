import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistViewModel extends ChangeNotifier {
  static const String _wishlistKey = 'wishlist_course_ids';
  List<String> _favoriteCourseIds = [];

  List<String> get favoriteCourseIds => _favoriteCourseIds;

  WishlistViewModel() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList(_wishlistKey);
    _favoriteCourseIds = storedList != null ? List<String>.from(storedList) : [];
    notifyListeners();
  }

  bool isFavorite(String courseId) {
    return _favoriteCourseIds.contains(courseId);
  }

  Future<void> toggleFavorite(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favoriteCourseIds.contains(courseId)) {
      _favoriteCourseIds.remove(courseId);
    } else {
      _favoriteCourseIds.add(courseId);
    }
    await prefs.setStringList(_wishlistKey, _favoriteCourseIds);
    notifyListeners();
  }
}
