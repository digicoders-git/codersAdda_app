import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:flutter/material.dart';

class MyLearningViewModel with ChangeNotifier {
  int _selectedCategoryIndex = 0;

 // Real working image URLs ke saath demo data
final List<MyLearningCourse> _freeCourses = [
  MyLearningCourse(
    id: "1",
    title: "Flutter Basics - Complete Beginner Guide",
    progress: 0.75,
    thumbnail: "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=250&fit=crop",
    instructor: "Sarah Wilson",
    purchaseDate: DateTime.now().subtract(Duration(days: 30)),
    isFree: true,
  ),
  MyLearningCourse(
    id: "2", 
    title: "Dart Programming Fundamentals",
    progress: 0.3,
    thumbnail: "https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=400&h=250&fit=crop",
    instructor: "Mike Chen",
    purchaseDate: DateTime.now().subtract(Duration(days: 15)),
    isFree: true,
  ),
];

final List<MyLearningCourse> _premiumCourses = [
  MyLearningCourse(
    id: "3",
    title: "Advanced Flutter Development", 
    progress: 0.6,
    thumbnail: "https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400&h=250&fit=crop",
    instructor: "Emily Davis",
    purchaseDate: DateTime.now().subtract(Duration(days: 45)),
    isFree: false,
  ),
  MyLearningCourse(
    id: "4",
    title: "Flutter Animations Masterclass",
    progress: 1.0,
    thumbnail: "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400&h=250&fit=crop",
    instructor: "John Smith", 
    purchaseDate: DateTime.now().subtract(Duration(days: 60)),
    isFree: false,
  ),
];

  final List<MyLearningPdf> _freePdfs = [
    MyLearningPdf(
      id: "1",
      title: "Flutter Architecture Guide",
      size: "3.2 MB",
      isFree: true,
      downloadUrl: "https://example.com/pdf1.pdf",
    ),
    MyLearningPdf(
      id: "2",
      title: "Dart Best Practices Handbook",
      size: "2.1 MB",
      isFree: true,
      downloadUrl: "https://example.com/pdf2.pdf",
    ),
  ];

  final List<MyLearningPdf> _premiumPdfs = [
    MyLearningPdf(
      id: "3",
      title: "Advanced State Management Patterns",
      size: "4.5 MB",
      isFree: false,
      downloadUrl: "https://example.com/pdf3.pdf",
    ),
    MyLearningPdf(
      id: "4",
      title: "Flutter Performance Optimization",
      size: "3.8 MB",
      isFree: false,
      downloadUrl: "https://example.com/pdf4.pdf",
    ),
  ];

  // Getters
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<MyLearningCourse> get freeCourses => _freeCourses;
  List<MyLearningCourse> get premiumCourses => _premiumCourses;
  List<MyLearningPdf> get freePdfs => _freePdfs;
  List<MyLearningPdf> get premiumPdfs => _premiumPdfs;

  // Methods
  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void updateCourseProgress(String courseId, double progress) {
    // Update course progress logic
    notifyListeners();
  }
}