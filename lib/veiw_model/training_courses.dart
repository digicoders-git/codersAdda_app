import 'package:coders_adda_app/models/training_courses.dart';
import 'package:coders_adda_app/views/training_pages/intern_apprent_training.dart';
import 'package:coders_adda_app/views/training_pages/summer_training.dart';
import 'package:coders_adda_app/views/training_pages/winter_traning.dart';
import 'package:flutter/material.dart';
import '../models/technology_model.dart';

class TrainingCoursesViewModel with ChangeNotifier {
  List<TrainingCourse> _courses = [];
  List<Technology> _allTechnologies = [];
  bool _isLoading = false;

  List<TrainingCourse> get courses => _courses;
  List<Technology> get allTechnologies => _allTechnologies;
  bool get isLoading => _isLoading;

  final List<Technology> _technologies = [
    Technology(id: '1', name: 'Flutter', icon: '📱', category: 'mobile'),
    Technology(id: '2', name: 'Android', icon: '🤖', category: 'mobile'),
    Technology(id: '3', name: 'iOS', icon: '🍎', category: 'mobile'),
    Technology(id: '4', name: 'React Native', icon: '⚛️', category: 'mobile'),
    Technology(id: '5', name: 'React.js', icon: '⚛️', category: 'web'),
    Technology(id: '6', name: 'Node.js', icon: '🟢', category: 'web'),
    Technology(id: '7', name: 'Python/Django', icon: '🐍', category: 'web'),
    Technology(id: '8', name: 'MERN Stack', icon: '📊', category: 'web'),
    Technology(id: '9', name: 'UI/UX Design', icon: '🎨', category: 'design'),
    Technology(id: '10', name: 'Graphic Design', icon: '✏️', category: 'design'),
    Technology(id: '11', name: 'Digital Marketing', icon: '📈', category: 'marketing'),
    Technology(id: '12', name: 'SEO/SEM', icon: '🔍', category: 'marketing'),
    Technology(id: '13', name: 'Java Spring Boot', icon: '☕', category: 'web'),
    Technology(id: '14', name: 'Data Science', icon: '📊', category: 'data'),
    Technology(id: '15', name: 'Machine Learning', icon: '🤖', category: 'ai'),
  ];

  TrainingCoursesViewModel() {
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    
    _allTechnologies = _technologies;
    
    _courses = [
      TrainingCourse(
        id: '1',
        title: 'Summer Training Program',
        type: 'summer_training',
        description: '45 days intensive training program with hands-on projects and industry exposure. Choose your preferred technology stack.',
        duration: '45 Days',
        location: 'Online & Offline',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        isFeatured: true,
        startDate: 'June 1, 2024',
        endDate: 'July 15, 2024',
        price: '₹4,999',
      ),
      TrainingCourse(
        id: '2',
        title: 'Winter Training Program',
        type: 'winter_training',
        description: '30 days winter training program during college break. Master new technologies with practical projects and certification.',
        duration: '30 Days',
        location: 'Online & Offline',
        imageUrl: 'https://picsum.photos/400/300?random=3',
        isFeatured: true,
        startDate: 'December 15, 2024',
        endDate: 'January 15, 2025',
        price: '₹3,999',
      ),
      TrainingCourse(
        id: '3',
        title: 'Internship / Apprenticeship',
        type: 'internship',
        description: '6 months professional internship with real-world projects and mentorship. Select your technology domain.',
        duration: '6 Months',
        location: 'Remote & On-site',
        imageUrl: 'https://picsum.photos/400/300?random=2',
        isFeatured: true,
        startDate: 'Flexible',
        endDate: 'Flexible',
        price: '₹9,999',
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void navigateToCourseDetails(BuildContext context, TrainingCourse course) {
    if (course.type == 'summer_training') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummerTrainingPage(technologies: _allTechnologies),
        ),
      );
    } else if (course.type == 'winter_training') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WinterTrainingPage(technologies: _allTechnologies),
        ),
      );
    } else if (course.type == 'internship') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InternApprentTrainingPage(),
        ),
      );
    }
  }

  // Filter technologies by category
  List<Technology> getTechnologiesByCategory(String category) {
    return _allTechnologies.where((tech) => tech.category == category).toList();
  }

  // Get featured courses
  List<TrainingCourse> get featuredCourses {
    return _courses.where((course) => course.isFeatured).toList();
  }

  // Search courses
  List<TrainingCourse> searchCourses(String query) {
    if (query.isEmpty) return _courses;
    
    return _courses.where((course) =>
      course.title.toLowerCase().contains(query.toLowerCase()) ||
      course.description.toLowerCase().contains(query.toLowerCase()) ||
      course.type.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}