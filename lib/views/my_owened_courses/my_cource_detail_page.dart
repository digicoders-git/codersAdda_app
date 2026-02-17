// import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
// import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
// import 'package:flutter/material.dart';

// class MyCourseDetailPage extends StatelessWidget {
//   final String courseId;

//   MyCourseDetailPage({required this.courseId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Course Details',
//           style: TextStyle(fontSize: AppSizer.deviceSp18),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(AppSizer.deviceWidth4),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: AppSizer.deviceHeight25,
//               decoration: BoxDecoration(
//                 color: AppColors.surfaceVariant,
//                 borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
//               ),
//               child: Center(
//                 child: Icon(
//                   Icons.play_circle_filled,
//                   color: AppColors.primaryColor,
//                   size: AppSizer.deviceWidth20,
//                 ),
//               ),
//             ),
//             SizedBox(height: AppSizer.deviceHeight2),
//             Text(
//               'Advanced Flutter Development',
//               style: TextStyle(
//                 fontSize: AppSizer.deviceSp20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: AppSizer.deviceHeight1),
//             Row(
//               children: [
//                 Icon(Icons.star, color: Colors.amber, size: AppSizer.deviceSp16),
//                 SizedBox(width: AppSizer.deviceWidth1),
//                 Text('4.8', style: TextStyle(fontSize: AppSizer.deviceSp14)),
//                 SizedBox(width: AppSizer.deviceWidth4),
//                 Icon(Icons.schedule, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
//                 SizedBox(width: AppSizer.deviceWidth1),
//                 Text('12 hours', style: TextStyle(fontSize: AppSizer.deviceSp14)),
//               ],
//             ),
//             SizedBox(height: AppSizer.deviceHeight3),
//             FilledButton(
//               onPressed: () {},
//               child: Text('Buy Individually - ₹199', style: TextStyle(fontSize: AppSizer.deviceSp14)),
//             ),
//             SizedBox(height: AppSizer.deviceHeight2),
//             OutlinedButton(
//               onPressed: () {},
//               child: Text('Subscribe to Access', style: TextStyle(fontSize: AppSizer.deviceSp14)),
//             ),
//             SizedBox(height: AppSizer.deviceHeight3),
//             Text(
//               'Course Content',
//               style: TextStyle(
//                 fontSize: AppSizer.deviceSp18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: AppSizer.deviceHeight2),
//             _buildCourseContent(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCourseContent() {
//     final modules = [
//       {'title': 'Introduction to Flutter', 'duration': '30 min', 'isFree': true},
//       {'title': 'Widgets Deep Dive', 'duration': '45 min', 'isFree': false},
//       {'title': 'State Management', 'duration': '60 min', 'isFree': false},
//     ];

//     return Column(
//       children: modules.map((module) {
//         return Card(
//           margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
//           child: ListTile(
//             leading: Icon(
//               module['isFree'] as bool ? Icons.lock_open : Icons.lock,
//               color: module['isFree'] as bool ? AppColors.successColor : AppColors.errorColor,
//               size: AppSizer.deviceSp16,
//             ),
//             title: Text(
//               module['title'] as String,
//               style: TextStyle(fontSize: AppSizer.deviceSp14),
//             ),
//             subtitle: Text(
//               module['duration'] as String,
//               style: TextStyle(fontSize: AppSizer.deviceSp12),
//             ),
//             trailing: module['isFree'] as bool 
//                 ? Icon(Icons.play_arrow, color: AppColors.primaryColor, size: AppSizer.deviceSp16)
//                 : Icon(Icons.lock, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }


import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/course_purchase_page.dart'; // Add this import
import 'package:coders_adda_app/models/course_model.dart'; // Add this import

class MyCourseDetailPage extends StatefulWidget {
  final String courseId;

  MyCourseDetailPage({required this.courseId});

  @override
  State<MyCourseDetailPage> createState() => _MyCourseDetailPageState();
}

class _MyCourseDetailPageState extends State<MyCourseDetailPage> {
  late Course _course;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  void _loadCourseData() {
    // Fetch course data from ViewModel or API
    // This is demo data - replace with actual data fetching
    _course = Course(
      id: widget.courseId,
      title: 'Advanced Flutter Development',
      description: 'Master advanced Flutter concepts...',
      instructor: 'Sarah Wilson',
      price: 199,
      thumbnail: '',
      category: 'Mobile Development',
      technology: 'Flutter',
      isFree: false,
      rating: 4.8,
      totalStudents: 1250,
      duration: '12 hours',
      totalLessons: 15,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Details',
          style: TextStyle(fontSize: AppSizer.deviceSp18),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer.deviceWidth4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AppSizer.deviceHeight25,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: AppColors.primaryColor,
                  size: AppSizer.deviceWidth20,
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              _course .title,
              style: TextStyle(
                fontSize: AppSizer.deviceSp20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: AppSizer.deviceSp16),
                SizedBox(width: AppSizer.deviceWidth1),
                Text('${_course .rating}', style: TextStyle(fontSize: AppSizer.deviceSp14)),
                SizedBox(width: AppSizer.deviceWidth4),
                Icon(Icons.schedule, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
                SizedBox(width: AppSizer.deviceWidth1),
                Text(_course .duration, style: TextStyle(fontSize: AppSizer.deviceSp14)),
                SizedBox(width: AppSizer.deviceWidth4),
                Icon(Icons.people, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
                SizedBox(width: AppSizer.deviceWidth1),
                Text('${_course .totalStudents}', style: TextStyle(fontSize: AppSizer.deviceSp14)),
              ],
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              _course .description,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight3),
            
            // Buy Now Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  _navigateToCheckout(context, _course );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                ),
                child: Text(
                  'Buy Now - ₹${_course .price}',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppSizer.deviceHeight2),
            
            // Alternative: Subscribe Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to subscription page
                  _showSubscriptionInfo(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight2),
                  side: BorderSide(color: AppColors.primaryColor),
                ),
                child: Text(
                  'Subscribe to Access All Courses',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            // Instructor Info
            _buildInstructorInfo(_course .instructor),
            
            SizedBox(height: AppSizer.deviceHeight3),
            
            Text(
              'Course Content',
              style: TextStyle(
                fontSize: AppSizer.deviceSp18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            _buildCourseContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorInfo(String instructor) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizer.deviceWidth12,
            height: AppSizer.deviceWidth12,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                instructor.split(' ').map((e) => e[0]).take(2).join(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizer.deviceSp14,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructor',
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(
                  instructor,
                  style: TextStyle(
                    fontSize: AppSizer.deviceSp14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to instructor profile
            },
            child: Text(
              'View Profile',
              style: TextStyle(
                fontSize: AppSizer.deviceSp12,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    final modules = [
      {'title': 'Introduction to Flutter', 'duration': '30 min', 'isFree': true},
      {'title': 'Widgets Deep Dive', 'duration': '45 min', 'isFree': false},
      {'title': 'State Management', 'duration': '60 min', 'isFree': false},
      {'title': 'API Integration', 'duration': '50 min', 'isFree': false},
      {'title': 'Animations', 'duration': '40 min', 'isFree': false},
    ];

    return Column(
      children: modules.map((module) {
        return Card(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1),
          child: ListTile(
            leading: Container(
              width: AppSizer.deviceWidth8,
              height: AppSizer.deviceWidth8,
              decoration: BoxDecoration(
                color: module['isFree'] as bool ? AppColors.successColor : AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                module['isFree'] as bool ? Icons.lock_open : Icons.lock,
                color: Colors.white,
                size: AppSizer.deviceSp12,
              ),
            ),
            title: Text(
              module['title'] as String,
              style: TextStyle(
                fontSize: AppSizer.deviceSp14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              module['duration'] as String,
              style: TextStyle(
                fontSize: AppSizer.deviceSp12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            trailing: module['isFree'] as bool 
                ? Icon(Icons.play_arrow, color: AppColors.primaryColor, size: AppSizer.deviceSp20)
                : Icon(Icons.lock, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
            onTap: module['isFree'] as bool ? () {
              // Play free lesson
              _playLesson(module['title'] as String);
            } : null,
          ),
        );
      }).toList(),
    );
  }

  void _navigateToCheckout(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseCheckoutPage(course: course),
      ),
    );
  }

  void _showSubscriptionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get access to all courses with our subscription plan:'),
            SizedBox(height: AppSizer.deviceHeight2),
            _buildFeatureItem('✓ Access to 100+ courses'),
            _buildFeatureItem('✓ New courses added monthly'),
            _buildFeatureItem('✓ Download for offline viewing'),
            _buildFeatureItem('✓ Certificate of completion'),
            _buildFeatureItem('✓ Priority support'),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'Starting at ₹999/month',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
            },
            child: Text('View Plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight0_5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: AppSizer.deviceSp16),
          SizedBox(width: AppSizer.deviceWidth2),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: AppSizer.deviceSp14),
            ),
          ),
        ],
      ),
    );
  }

  void _playLesson(String lessonTitle) {
    // Implement lesson playback
    print('Playing lesson: $lessonTitle');
  }
}