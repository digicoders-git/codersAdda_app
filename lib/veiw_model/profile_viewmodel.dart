import 'dart:convert';
import 'dart:io';
import 'package:coders_adda_app/models/profile_model.dart';
import 'package:coders_adda_app/services/profile_service.dart';
import 'package:flutter/material.dart';

class ProfileViewModel with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  UserProfile? _user;
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;

  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  List<Achievement> _achievements = [
    Achievement(
      title: "Flutter Expert",
      description: "Completed Advanced Flutter Development Course",
      icon: "🎯",
      achievedAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    Achievement(
      title: "Top Performer",
      description: "Scored 95% in Programming Fundamentals",
      icon: "🏆",
      achievedAt: DateTime.now().subtract(Duration(days: 60)),
    ),
    Achievement(
      title: "Project Master",
      description: "Built 5+ Real World Applications",
      icon: "🚀",
      achievedAt: DateTime.now().subtract(Duration(days: 90)),
    ),
  ];

  bool _notificationsEnabled = true;

  List<Achievement> get achievements => _achievements;
  bool get notificationsEnabled => _notificationsEnabled;

  // Fetch Profile from API
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileService.getUserProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  String get memberSince {
    if (_user == null) return '0 months';
    final months = DateTime.now().difference(_user!.createdAt).inDays ~/ 30;
    return '$months months';
  }

  // Edit Profile Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController branchController = TextEditingController(); // Added Branch
  TextEditingController semesterController = TextEditingController();
  TextEditingController technologyController = TextEditingController(); // This will handle comma separated input
  TextEditingController githubController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController portfolioController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController skillsController = TextEditingController(); // Added Skills
  
  bool initialized = false;

  void initializeWithUser(UserProfile user) { 
    if (initialized) return;
    
    nameController.text = user.name;
    emailController.text = user.email;
    collegeController.text = user.college;
    courseController.text = user.course;
    branchController.text = user.branch;
    semesterController.text = user.semester;
    technologyController.text = user.technology.join(", ");
    githubController.text = user.github;
    linkedinController.text = user.linkedin;
    portfolioController.text = user.portfolio;
    bioController.text = user.about;
    skillsController.text = user.skills.join(", ");
    
    initialized = true;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Prepare social links as JSON string
      final socialLinks = jsonEncode({
        'github': githubController.text.trim(),
        'linkedin': linkedinController.text.trim(),
        'portfolio': portfolioController.text.trim(),
      });

      // Prepare technology and skills as JSON array strings
      final technologyList = technologyController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final skillsList = skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final Map<String, String> fields = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'about': bioController.text.trim(),
        'college': collegeController.text.trim(),
        'course': courseController.text.trim(),
        'semester': semesterController.text.trim(),
        'branch': branchController.text.trim().isEmpty ? 'Computer Science' : branchController.text.trim(),
        'socialLinks': socialLinks,
        'technology': jsonEncode(technologyList),
        'skills': jsonEncode(skillsList),
      };

      await _profileService.updateProfileMultipart(fields, imageFile: _selectedImage);
      
      await fetchUserProfile(); // Refresh local data
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearProfile() {
    _user = null;
    _selectedImage = null;
    _errorMessage = null;
    initialized = false;
    nameController.clear();
    emailController.clear();
    collegeController.clear();
    courseController.clear();
    branchController.clear();
    semesterController.clear();
    technologyController.clear();
    githubController.clear();
    linkedinController.clear();
    portfolioController.clear();
    bioController.clear();
    skillsController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    collegeController.dispose();
    courseController.dispose();
    branchController.dispose();
    semesterController.dispose();
    technologyController.dispose();
    githubController.dispose();
    linkedinController.dispose();
    portfolioController.dispose();
    bioController.dispose();
    skillsController.dispose();
    super.dispose();
  }
}