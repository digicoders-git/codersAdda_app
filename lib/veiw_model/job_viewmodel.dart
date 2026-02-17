
import 'package:coders_adda_app/models/job_model.dart';
import 'package:flutter/material.dart';

class JobsViewModel with ChangeNotifier {
  final List<JobDetail> _jobs = [
    JobDetail(
      id: "1",
      title: "Senior Flutter Developer",
      company: "TechCorp Inc.",
      location: "Lucknow",
      experience: "3-5 years",
      jobType: "Work From Home",
      skills: ["Flutter", "Dart", "Firebase", "REST API"],
      salary: "₹12-18 LPA",
      position: "Senior Developer",
      totalOpenings: 5,
      companyAddress: "123 Tech Park, Bangalore, Karnataka",
      companyEmail: "hr@techcorp.com",
      companyMobile: "+91 9876543210",
      companyWebsite: "https://techcorp.com",
      description: "We are looking for an experienced Flutter developer...",
      applyLink: "https://example.com/apply/1",
      addedDate: "15 Dec 2023",
      lastDate: "30 Jan 2024",
    ),
    JobDetail(
      id: "2",
      title: "Junior Flutter Developer",
      company: "StartUp Solutions",
      location: "Noida",
      experience: "Fresher",
      jobType: "Work From Office",
      skills: ["Flutter", "Dart", "Git", "OOP"],
      salary: "₹6-8 LPA",
      position: "Junior Developer",
      totalOpenings: 10,
      companyAddress: "456 Startup Lane, Hyderabad, Telangana",
      companyEmail: "careers@startupsol.com",
      companyMobile: "+91 9123456780",
      companyWebsite: "https://startupsol.com",
      description: "Fresh graduates are welcome to apply...",
      applyLink: "https://example.com/apply/2",
      addedDate: "18 Dec 2023",
      lastDate: "15 Feb 2024",
    ),
    JobDetail(
      id: "3",
      title: "Flutter Team Lead",
      company: "Enterprise Tech",
      location: "Delhi",
      experience: "5-8 years",
      jobType: "Hybrid",
      skills: ["Flutter", "Team Management", "Architecture", "CI/CD"],
      salary: "₹20-25 LPA",
      position: "Team Lead",
      totalOpenings: 2,
      companyAddress: "789 Corporate Tower, Delhi",
      companyEmail: "jobs@enterprisetech.com",
      companyMobile: "+91 9988776655",
      companyWebsite: "https://enterprisetech.com",
      description: "Lead our Flutter development team...",
      applyLink: "https://example.com/apply/3",
      addedDate: "20 Dec 2023",
      lastDate: "10 Feb 2024",
    ),
    JobDetail(
      id: "4",
      title: "Android Engineer",
      company: "MobileFirst",
      location: "Bangalore",
      experience: "2-4 years",
      jobType: "Work From Office",
      skills: ["Android", "Kotlin", "Java", "XML"],
      salary: "₹15-20 LPA",
      position: "Android Developer",
      totalOpenings: 3,
      companyAddress: "321 Mobile Street, Bangalore",
      companyEmail: "hr@mobilefirst.com",
      companyMobile: "+91 8899776655",
      companyWebsite: "https://mobilefirst.com",
      description: "Join our team to build amazing mobile applications...",
      applyLink: "https://example.com/apply/4",
      addedDate: "22 Dec 2023",
      lastDate: "20 Feb 2024",
    ),
    JobDetail(
      id: "5",
      title: "iOS Developer",
      company: "Apple Solutions",
      location: "Remote",
      experience: "3-6 years",
      jobType: "Work From Home",
      skills: ["iOS", "Swift", "UIKit", "Core Data"],
      salary: "₹18-22 LPA",
      position: "iOS Developer",
      totalOpenings: 4,
      companyAddress: "654 iOS Park, Pune",
      companyEmail: "careers@apple-sol.com",
      companyMobile: "+91 7766554433",
      companyWebsite: "https://apple-sol.com",
      description: "Looking for experienced iOS developers...",
      applyLink: "https://example.com/apply/5",
      addedDate: "25 Dec 2023",
      lastDate: "25 Feb 2024",
    ),
  ];

  final Set<String> _viewedJobs = {};
  final Set<String> _appliedJobs = {};
  static const int _maxFreeApplications = 3;

  List<JobDetail> get allJobs => _jobs;

  bool canApplyForJob(String jobId) {
    return _appliedJobs.contains(jobId) || _appliedJobs.length < _maxFreeApplications;
  }

  void applyForJob(String jobId) {
    if (!_appliedJobs.contains(jobId)) {
      _appliedJobs.add(jobId);
      notifyListeners();
    }
  }

  int get remainingFreeApplications => _maxFreeApplications - _appliedJobs.length;
  bool get hasFreeApplicationsRemaining => _appliedJobs.length < _maxFreeApplications;

String searchQuery = '';
  String selectedJobType = '';
  String selectedExperience = '';
  Set<String> selectedSkills = {};
  
  List<JobDetail> get filteredJobs {
    List<JobDetail> filtered = allJobs;
    

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((job) =>
        job.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        job.skills.any((skill) => skill.toLowerCase().contains(searchQuery.toLowerCase())) ||
        job.company.toLowerCase().contains(searchQuery.toLowerCase()) ||
        job.location.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    

    if (selectedJobType.isNotEmpty && selectedJobType != 'All Types') {
      filtered = filtered.where((job) => job.jobType == selectedJobType).toList();
    }
    

    if (selectedExperience.isNotEmpty && selectedExperience != 'All Levels') {
      filtered = filtered.where((job) => job.experience == selectedExperience).toList();
    }
    

    if (selectedSkills.isNotEmpty) {
      filtered = filtered.where((job) =>
        selectedSkills.every((skill) => job.skills.contains(skill))
      ).toList();
    }
    
    return filtered;
  }
  
  List<String> get availableJobTypes {
    return allJobs.map((job) => job.jobType).toSet().toList()..sort();
  }
  
  List<String> get availableExperiences {
    return allJobs.map((job) => job.experience).toSet().toList()..sort();
  }
  
  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        (selectedJobType.isNotEmpty && selectedJobType != 'All Types') ||
        (selectedExperience.isNotEmpty && selectedExperience != 'All Levels') ||
        selectedSkills.isNotEmpty;
  }
  

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }
  
  void setSelectedJobType(String type) {
    selectedJobType = type;
    notifyListeners();
  }
  
  void setSelectedExperience(String experience) {
    selectedExperience = experience;
    notifyListeners();
  }
  
  void addSelectedSkill(String skill) {
    selectedSkills.add(skill);
    notifyListeners();
  }
  
  void removeSelectedSkill(String skill) {
    selectedSkills.remove(skill);
    notifyListeners();
  }
  
  void clearAllFilters() {
    searchQuery = '';
    selectedJobType = '';
    selectedExperience = '';
    selectedSkills.clear();
    notifyListeners();
  }

 
 
}
