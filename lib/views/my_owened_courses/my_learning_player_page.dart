import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_content_tab.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_faq_tab_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_review_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyLearningCoursePlayer extends StatefulWidget {
  const MyLearningCoursePlayer({Key? key}) : super(key: key);

  @override
  State<MyLearningCoursePlayer> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<MyLearningCoursePlayer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDescriptionExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoursePlayerViewModel(),
      child: Scaffold(
        body: Column(
          children: [
            // Video Player Container
            Container(
              width: double.infinity,
              height: AppSizer.deviceHeight25, // 25% of screen height
              color: AppColors.onSurfaceVariant,
              child: Stack(
                children: [
                  Positioned(
                    bottom: AppSizer.deviceHeight1,
                    left: AppSizer.deviceWidth2,
                    right: AppSizer.deviceWidth2,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.white, size: AppSizer.deviceSp24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.replay_10, color: Colors.white, size: AppSizer.deviceSp20),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.forward_10, color: Colors.white, size: AppSizer.deviceSp20),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.white, size: AppSizer.deviceSp20),
                          onPressed: () {},
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          icon: Icon(Icons.fullscreen, color: Colors.white, size: AppSizer.deviceSp20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Video Info Section
            Container(
              width: double.infinity,
              color: AppColors.cardColor,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Title
                  Text(
                    'Introduction to Ethical Hacking - Complete Guide',
                    style: TextStyle(
                      fontSize: AppSizer.deviceSp18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Row(
                    children: [
                      Text(
                        '200.7k views',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Container(
                        width: AppSizer.deviceWidth1,
                        height: AppSizer.deviceWidth1,
                        decoration: BoxDecoration(
                          color: AppColors.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppSizer.deviceWidth2),
                      Text(
                        '2 months ago',
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  AnimatedCrossFade(
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn the fundamentals of ethical hacking in this comprehensive tutorial. This course covers everything from basic concepts to advanced...',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp16,
                            color: AppColors.textColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = true;
                            });
                          },
                          child: Text(
                            'View more',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn the fundamentals of ethical hacking in this comprehensive tutorial. This course covers everything from basic concepts to advanced techniques used by professionals.\n\n'
                          'What you will learn:\n',
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            color: AppColors.textColor,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = false;
                            });
                          },
                          child: Text(
                            'View less',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: _isDescriptionExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Divider(height: 1, color: AppColors.outline),
                  SizedBox(height: AppSizer.deviceHeight1),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outline),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                ),
                tabs: const [
                  Tab(text: 'Course Content'),
                  Tab(text: 'FAQs'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
            
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CourseContentTab(),
                  FAQsTab(),
                  ReviewsTab(),
                ],
              ),
            ),
            
            // Upgrade Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              color: AppColors.buttonColor,
              child: Text(
                'Upgrade for Certificate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardColor,
                ),
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
          ],
        ),
      ),
    );
  }
}