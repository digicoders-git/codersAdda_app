import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/views/home_pages/all_course_details_page.dart';
import 'package:coders_adda_app/views/home_pages/all_cource_page.dart';
import 'package:coders_adda_app/views/buy_new_pdf_pages/pdf_page.dart';
import 'package:coders_adda_app/views/subscription_pages/subscrption_page.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static Future<void> navigateTo(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
static Future<void> navigateToPdfPage(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PdfPage()),
  );
}
  static Future<void> navigateToCourseDetail(BuildContext context, Course course) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllCourseDetailPage(course: course)),
    );
  }

  static Future<void> navigateToCoursePage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllCoursePage()),
    );
  }
static Future<void> navigateToSubscriptionPage(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SubscriptionPage()),
  );
}

  static Future<void> navigateAndReplace(BuildContext context, Widget page) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}