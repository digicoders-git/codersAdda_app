import 'package:flutter/material.dart';
import 'package:coders_adda_app/models/my_learning_courses_play_model.dart';

class CoursePlayerViewModel extends ChangeNotifier {
  late final CourseVideo _courseModel;

  CoursePlayerViewModel() {
    _courseModel = CourseVideo(
      overallRating: 4.6,
      ratingDistribution: {5: 82, 4: 7, 3: 5, 2: 1, 1: 5},
      reviews: [
        ReviewItem(
          name: 'Rangrez Abuzar Ali Ashraf Ali',
          initial: 'R',
          rating: 5,
          comment: 'we need update lectures.',
        ),
        ReviewItem(
          name: 'Lakhjeet',
          initial: 'L',
          rating: 5,
          comment: 'sir kali linux downlod khaa se kre aap discription me link add kr do pless',
        ),
        ReviewItem(
          name: 'Tushar Kumar',
          initial: 'T',
          rating: 5,
          comment: 'Great course content!',
        ),
      ],
      faqs: [
        FAQItem(
          question: 'What is ethical hacking?',
          answer: 'An permitted attempt to acquire unauthorised access to a computer system, application, or data is referred to as ethical hacking. Duplicating the techniques and behaviours of malevolent attackers is part of carrying out an ethical hack.',
        ),
        FAQItem(
          question: 'What are different types of ethical hacking?',
          answer: 'Different types include Web Application Hacking, System Hacking, Web Server Hacking, Wireless Network Hacking, and Social Engineering.',
        ),
        FAQItem(
          question: 'Can we hack wifi using Python?',
          answer: 'Yes, Python can be used for network security testing including WiFi security assessment with proper authorization.',
        ),
      ],
      courseSections: [
        CourseSection(title: 'Getting Started', topics: []),
        CourseSection(title: 'Basics of Ethical Hacking', topics: []),
        CourseSection(title: 'Ethical Hacking Phases', topics: []),
        CourseSection(title: 'Hacking and IP Addresses', topics: []),
        CourseSection(title: 'Hacking and Ports', topics: []),
        CourseSection(title: 'Hacking and Domain Name Servers', topics: []),
      ],
    );
  }

  CourseVideo get courseModel => _courseModel;
  
  double get overallRating => _courseModel.overallRating;
  
  Map<int, int> get ratingDistribution => _courseModel.ratingDistribution;
  
  List<ReviewItem> get reviews => _courseModel.reviews;
  
  List<FAQItem> get faqs => _courseModel.faqs;
  
  List<CourseSection> get courseSections => _courseModel.courseSections;
}



