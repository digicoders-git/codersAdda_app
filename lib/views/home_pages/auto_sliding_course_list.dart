import 'dart:async';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';

class AutoSlidingCourseList extends StatefulWidget {
  final List<Course> courses;

  const AutoSlidingCourseList({Key? key, required this.courses}) : super(key: key);

  @override
  State<AutoSlidingCourseList> createState() => _AutoSlidingCourseListState();
}

class _AutoSlidingCourseListState extends State<AutoSlidingCourseList> {
  late ScrollController _scrollController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.courses.isEmpty || !_scrollController.hasClients) return;

      final double maxScroll = _scrollController.position.maxScrollExtent;
      final double currentScroll = _scrollController.offset;
      final double itemWidth = AppSizer.deviceWidth43 + AppSizer.deviceWidth1;

      _currentIndex++;
      if (_currentIndex >= widget.courses.length) {
        _currentIndex = 0;
      }

      double targetScroll = _currentIndex * itemWidth;

      // Reset to start if we exceed the scroll limit
      if (targetScroll > maxScroll) {
        targetScroll = 0;
        _currentIndex = 0;
      }

      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courses.isEmpty) return const SizedBox();

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.courses.length,
      itemBuilder: (context, index) {
        final course = widget.courses[index];
        return GestureDetector(
          onTap: () {
            NavigationService.navigateToCourseDetail(context, course);
          },
          child: Container(
            width: AppSizer.deviceWidth43,
            margin: EdgeInsets.only(right: AppSizer.deviceWidth1),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Container with Free Badge
                  Stack(
                    children: [
                      Container(
                        height: AppSizer.deviceHeight13,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppSizer.deviceWidth3),
                            topRight: Radius.circular(AppSizer.deviceWidth3),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(course.thumbnail),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Free Badge
                      Positioned(
                        top: AppSizer.deviceHeight1,
                        left: AppSizer.deviceWidth2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer.deviceWidth2,
                            vertical: AppSizer.deviceHeight0_5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_open,
                                color: AppColors.successColor,
                                size: AppSizer.deviceSp20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(AppSizer.deviceWidth3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: AppSizer.deviceHeight0_5),

                        // Instructor
                        Text(
                          course.instructor,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),

                        // Rating and Duration Row
                        Row(
                          children: [
                            // Rating
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth1_5,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppColors.buttonColor,
                                    size: AppSizer.deviceSp16,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.7',
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.buttonColor,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '(1.8k)',
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSizer.deviceWidth2),

                            // Duration
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer.deviceWidth1_5,
                                vertical: AppSizer.deviceHeight0_5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_outlined,
                                    color: AppColors.primaryColor,
                                    size: AppSizer.deviceSp12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '8h',
                                    style: TextStyle(
                                      fontSize: AppSizer.deviceSp14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizer.deviceHeight1),

                        // Free Price Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '₹0',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp14,
                                    color: AppColors.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: AppSizer.deviceWidth1),
                                Text(
                                  '₹${course.price}',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp10,
                                    color: AppColors.onSurfaceVariant,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
