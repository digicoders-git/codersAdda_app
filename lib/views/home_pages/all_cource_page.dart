import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/course_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllCoursePage extends StatefulWidget {
  final CourseViewModel viewModel = CourseViewModel();
  AllCoursePage({super.key});

  @override
  State<AllCoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<AllCoursePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      widget.viewModel.setSelectedTabIndex(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'All Courses',
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primaryColor,
            tabs: [
              Tab(text: 'Free Courses'),
              Tab(text: 'Premium Courses'),
            ],
          ),
        ),
        body: Consumer<CourseViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Technology Filter Chips
                _buildTechnologyFilter(viewModel),

                // Courses Grid
                Expanded(
                  child: viewModel.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => viewModel.fetchCourses(),
                          child: _buildCoursesGrid(context, viewModel),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTechnologyFilter(CourseViewModel viewModel) {
    return Container(
      height: AppSizer.deviceHeight8,
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected =
              viewModel.selectedTechnology == category.technology;

          return Container(
            margin: EdgeInsets.only(
              right: AppSizer.deviceWidth2,
              top: AppSizer.deviceHeight1,
              bottom: AppSizer.deviceHeight1,
            ),
            child: FilterChip(
              label: Text(
                '${category.name} (${category.courseCount})',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  color: isSelected ? Colors.white : AppColors.textColor,
                ),
              ),
              selected: isSelected,
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryColor,
              checkmarkColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.outline,
                ),
              ),
              onSelected: (selected) {
                viewModel.setSelectedTechnology(category.technology);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursesGrid(BuildContext context, CourseViewModel viewModel) {
    final courses = viewModel.filteredCourses;

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: AppSizer.deviceSp64,
              color: Colors.grey,
            ),
            SizedBox(height: AppSizer.deviceHeight2),
            Text(
              'No Courses Found',
              style: TextStyle(
                fontSize: AppSizer.deviceSp19,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: AppSizer.deviceHeight1),
            Text(
              'Try selecting a different technology',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: AppSizer.deviceWidth2,
        mainAxisSpacing: AppSizer.deviceHeight2,
        childAspectRatio: 1.15,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(context, course);
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return GestureDetector(
      onTap: () {
        // Navigate to Course Detail Page
        NavigationService.navigateToCourseDetail(context, course);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.cardColor, Colors.grey.shade50],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Thumbnail with Overlay
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: AppSizer.deviceHeight16,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizer.deviceWidth4),
                        topRight: Radius.circular(AppSizer.deviceWidth4),
                      ),
                      image: course.thumbnail.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(course.thumbnail),
                              fit: BoxFit.cover,
                            )
                          : null, // Remove AssetImage fallback
                    ),
                    child: course.thumbnail.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: AppColors.primaryColor,
                              size: AppSizer.deviceSp32,
                            ),
                          )
                        : null,
                  ),

                  // Gradient Overlay
                  Container(
                    width: double.infinity,
                    height: AppSizer.deviceHeight16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizer.deviceWidth4),
                        topRight: Radius.circular(AppSizer.deviceWidth4),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Free/Paid Badge - Top Left
                  Positioned(
                    top: AppSizer.deviceHeight1,
                    left: AppSizer.deviceWidth1,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth2,
                        vertical: AppSizer.deviceHeight0_5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fire icon with yellow/orange gradient
                          if (!course.isFree)
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.deepOrange,
                                    // Colors.yellow,
                                    Colors.orange,
                                  ],
                                  stops: [0.0, 1.0],
                                ).createShader(bounds);
                              },
                              child: Icon(
                                Icons.local_fire_department,
                                color: Colors
                                    .white, // This color will be overridden by the gradient
                                size: AppSizer.deviceSp18,
                              ),
                            ),

                          // Lock icon with green gradient
                          if (course.isFree)
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    AppColors.successColor,
                                    //Colors.lightGreen,
                                    //Colors.greenAccent,
                                  ],
                                  stops: [1.0],
                                ).createShader(bounds);
                              },
                              child: Icon(
                                Icons.lock_open,
                                color: Colors
                                    .white, // This color will be overridden by the gradient
                                size: AppSizer.deviceSp18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Technology Badge - Top Right
                  // Positioned(
                  //   top: AppSizer.deviceHeight1,
                  //   right: AppSizer.deviceWidth2,
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: AppSizer.deviceWidth2,
                  //       vertical: AppSizer.deviceHeight0_5,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.primaryColor.withOpacity(0.9),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Text(
                  //       course.technology,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: AppSizer.deviceSp10,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              // Course Details
              Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Instructor
                    // Row(
                    //   children: [
                    //     Icon(
                    //       Icons.person,
                    //       color: AppColors.onSurfaceVariant,
                    //       size: AppSizer.deviceSp14,
                    //     ),
                    //     SizedBox(width: AppSizer.deviceWidth1),
                    //     Expanded(
                    //       child: Text(
                    //         course.instructor,
                    //         style: TextStyle(
                    //           fontSize: AppSizer.deviceSp13,
                    //           color: AppColors.onSurfaceVariant,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //         maxLines: 1,
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // SizedBox(height: AppSizer.deviceHeight1),

                    // Course Stats Row
                    Row(
                      children: [
                        // Rating
                        _buildCourseStatItem(
                          Icons.star,
                          course.rating.toString(),
                          AppColors.buttonColor,
                        ),

                        SizedBox(width: AppSizer.deviceWidth1),

                        // Duration
                        _buildCourseStatItem(
                          Icons.access_time_filled_outlined,
                          course.duration,
                          AppColors.buttonColor,
                        ),

                        SizedBox(width: AppSizer.deviceWidth1),

                        // Videos Count
                        _buildCourseStatItem(
                          Icons.video_library,
                          '${course.totalLessons} lessons',
                          AppColors.buttonColor,
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Price and Enrollments
                    Container(
                      padding: EdgeInsets.all(AppSizer.deviceWidth2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp14,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: AppSizer.deviceHeight0_5),
                                Text(
                                  course.isFree ? 'FREE' : '₹${course.price}',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp16,
                                    fontWeight: FontWeight.w700,
                                    color: course.isFree
                                        ? AppColors.successColor
                                        : AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Students Count
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Students',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp14,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: AppSizer.deviceHeight0_5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: AppColors.primaryColor,
                                      size: AppSizer.deviceSp14,
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth1),
                                    Text(
                                      '${course.totalStudents}+',
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for course stats
  Widget _buildCourseStatItem(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizer.deviceHeight1,
          horizontal: AppSizer.deviceWidth1,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppSizer.deviceSp20),
            SizedBox(width: AppSizer.deviceWidth1),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
