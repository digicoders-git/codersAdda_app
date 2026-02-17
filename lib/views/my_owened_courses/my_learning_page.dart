import 'package:coders_adda_app/models/my_learning_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_pdf_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_player_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyLearningPage extends StatelessWidget {
  final MyLearningViewModel viewModel = MyLearningViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Consumer<MyLearningViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'My Learning',
                style: TextStyle(
                  fontSize: AppSizer.deviceSp20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Column(
              children: [
                // Tab Buttons
                _buildTabButtons(context, viewModel),

                // Content Area
                Expanded(child: _buildSelectedContent(context, viewModel)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButtons(BuildContext context, MyLearningViewModel viewModel) {
    final List<TabItem> tabs = [
      TabItem(title: 'Free Courses', icon: Icons.school),
      TabItem(title: 'Premium Courses', icon: Icons.workspace_premium),
      TabItem(title: 'Free E-Books', icon: Icons.menu_book),
      TabItem(title: 'Premium E-Books', icon: Icons.library_books),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizer.deviceWidth4,
        vertical: AppSizer.deviceHeight2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = viewModel.selectedCategoryIndex == index;
            return Padding(
              padding: EdgeInsets.only(right: AppSizer.deviceWidth3),
              child: ElevatedButton(
                onPressed: () {
                  viewModel.selectCategory(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade100,
                  foregroundColor: isSelected
                      ? Colors.white
                      : AppColors.textColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer.deviceWidth4,
                    vertical: AppSizer.deviceHeight2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                  ),
                  elevation: isSelected ? 2 : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: AppSizer.deviceSp16),
                    SizedBox(width: AppSizer.deviceWidth2),
                    Text(
                      tab.title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(
    BuildContext context,
    MyLearningViewModel viewModel,
  ) {
    switch (viewModel.selectedCategoryIndex) {
      case 0:
        return _buildCoursesList(
          context,
          viewModel.freeCourses,
          'Free Courses',
        );
      case 1:
        return _buildCoursesList(
          context,
          viewModel.premiumCourses,
          'Premium Courses',
        );
      case 2:
        return _buildPdfsList(context, viewModel.freePdfs, 'Free E-Books');
      case 3:
        return _buildPdfsList(
          context,
          viewModel.premiumPdfs,
          'Premium E-Books',
        );
      default:
        return _buildCoursesList(
          context,
          viewModel.freeCourses,
          'Free Courses',
        );
    }
  }

  Widget _buildCoursesList(
    BuildContext context,
    List<MyLearningCourse> courses,
    String title,
  ) {
    if (courses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.video_library,
        title: 'No $title',
        message: 'Explore our courses and start learning!',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(context, course);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, MyLearningCourse course) {
    // Demo data - you can add these to your model
    final double rating = 4.5;
    final int totalRatings = 128;
    final String duration = "8h 30m";
    final int totalVideos = 45;
    final String category = "Flutter Development";

    return GestureDetector(
      onTap: () {
        // Navigate to course player
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyLearningCoursePlayer()),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: AppSizer.deviceHeight3),
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
              colors: [Colors.white, Colors.grey.shade50],
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
                    height: AppSizer.deviceHeight22,
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
                          : null,
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
                    height: AppSizer.deviceHeight22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizer.deviceWidth4),
                        topRight: Radius.circular(AppSizer.deviceWidth4),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Progress Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: Colors.black.withOpacity(0.4),
                      color: course.progress == 1.0
                          ? AppColors.successColor
                          : AppColors.primaryColor,
                      minHeight: AppSizer.deviceHeight0_5,
                    ),
                  ),

                  // Progress Percentage
                  if (course.progress > 0)
                    Positioned(
                      bottom: AppSizer.deviceHeight1,
                      right: AppSizer.deviceWidth3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth2,
                          vertical: AppSizer.deviceHeight0_5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(course.progress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizer.deviceSp12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Category Badge
                  Positioned(
                    top: AppSizer.deviceHeight1,
                    left: AppSizer.deviceWidth3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizer.deviceWidth3,
                        vertical: AppSizer.deviceHeight0_5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizer.deviceSp13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Completed Badge
                  if (course.progress == 1.0)
                    Positioned(
                      top: AppSizer.deviceHeight1,
                      right: AppSizer.deviceWidth3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer.deviceWidth3,
                          vertical: AppSizer.deviceHeight0_5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: AppSizer.deviceSp12,
                            ),
                            SizedBox(width: AppSizer.deviceWidth1),
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSizer.deviceSp10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Course Details
              Padding(
                padding: EdgeInsets.all(AppSizer.deviceWidth4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: AppSizer.deviceSp18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Instructor
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.onSurfaceVariant,
                          size: AppSizer.deviceSp16,
                        ),
                        SizedBox(width: AppSizer.deviceWidth2),
                        Expanded(
                          child: Text(
                            'By ${course.instructor}',
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp14,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight1),

                    // Course Stats Row
                    Row(
                      children: [
                        // Rating
                        _buildStatItem(
                          Icons.star,
                          rating.toString(),
                          AppColors.buttonColor,
                        ),

                        SizedBox(width: AppSizer.deviceWidth3),

                        // Duration
                        _buildStatItem(
                          Icons.access_time,
                          duration,
                          AppColors.buttonColor,
                        ),

                        SizedBox(width: AppSizer.deviceWidth3),

                        // Videos Count
                        _buildStatItem(
                          Icons.video_library,
                          '$totalVideos videos',
                          AppColors.buttonColor,
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizer.deviceHeight2),

                    // Progress and Action Button
                    Container(
                      padding: EdgeInsets.all(AppSizer.deviceWidth3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth3,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Progress Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp12,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: AppSizer.deviceHeight0_5),
                                Text(
                                  '${(course.progress * 100).toInt()}% completed',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Button
                          Container(
                            width: AppSizer.deviceWidth14,
                            height: AppSizer.deviceWidth14,
                            decoration: BoxDecoration(
                              color: course.progress == 1.0
                                  ? AppColors.successColor
                                  : AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              course.progress == 0.0
                                  ? Icons.play_arrow
                                  : course.progress == 1.0
                                  ? Icons.replay
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: AppSizer.deviceSp18,
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
  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizer.deviceHeight1,
          horizontal: AppSizer.deviceWidth2,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizer.deviceSp16,
              height: AppSizer.deviceSp16,
              child: Icon(icon, color: color, size: AppSizer.deviceSp16),
            ),
            SizedBox(width: AppSizer.deviceWidth1),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp14,
                  fontWeight: FontWeight.w600,
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

  Widget _buildPdfsList(
    BuildContext context,
    List<MyLearningPdf> pdfs,
    String title,
  ) {
    if (pdfs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.picture_as_pdf,
        title: 'No $title',
        message: 'No PDFs available in this category',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight3),

          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizer.deviceHeight3,
              crossAxisSpacing: AppSizer.deviceWidth3,
              childAspectRatio: 3 / 5.2,
            ),
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final pdf = pdfs[index];
              return _buildPdfCard(context, pdf);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context, MyLearningPdf pdf) {
    // Demo data for additional details
    final int pageCount = 45;
    final double rating = 4.5;
    final int totalRatings = 128;

    return GestureDetector(
      onTap: () {
        // Navigate to PDF detailed page for full view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyLearningPdfViewer(pdf: pdf),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizer.deviceWidth4),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSizer.deviceWidth4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Icon with Badge
              Stack(
                children: [
                  Container(
                    height: AppSizer.deviceHeight15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSizer.deviceWidth3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: AppSizer.deviceSp32,
                          ),
                          SizedBox(height: AppSizer.deviceHeight1),
                          Text(
                            "$pageCount Pages",
                            style: TextStyle(
                              fontSize: AppSizer.deviceSp12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Free/Premium Badge - Top Left
                  Positioned(
                    top: AppSizer.deviceHeight1,
                    left: AppSizer.deviceWidth2,
                    child: Container(
                      padding: EdgeInsets.symmetric(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pdf.isFree)
                            Icon(
                              Icons.lock_open,
                              color: AppColors.successColor,
                              size: AppSizer.deviceSp20,
                            )
                          else
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: AppSizer.deviceSp20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizer.deviceHeight2),

              // Content area that can expand
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PDF Title
                        Text(
                          pdf.title,
                          style: TextStyle(
                            fontSize: AppSizer.deviceSp15,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppSizer.deviceHeight1),

                        // PDF Size
                        Row(
                          children: [
                            Text(
                              pdf.size,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp13,
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppSizer.deviceWidth1),
                            // Rating Section
                            Row(
                              children: [
                                // Star Rating
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.buttonColor,
                                      size: AppSizer.deviceSp16,
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth1),
                                    Text(
                                      rating.toString(),
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(width: AppSizer.deviceWidth2),

                                // Total Ratings
                                Text(
                                  '($totalRatings)',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        //SizedBox(height: AppSizer.deviceHeight1),

                        // Views Count
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: AppColors.onSurfaceVariant,
                              size: AppSizer.deviceSp14,
                            ),
                            SizedBox(width: AppSizer.deviceWidth1),
                            Text(
                              '${(totalRatings * 5).toInt()}+ views',
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Open PDF Text
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizer.deviceHeight1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSizer.deviceWidth2,
                        ),
                      ),
                      child: Text(
                        'Tap to Open PDF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppSizer.deviceSp12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizer.deviceSp64, color: Colors.grey),
          SizedBox(height: AppSizer.deviceHeight3),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizer.deviceSp18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          Text(
            message,
            style: TextStyle(fontSize: AppSizer.deviceSp14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TabItem {
  final String title;
  final IconData icon;

  TabItem({required this.title, required this.icon});
}

final List<TabItem> tabs = [
  TabItem(title: 'Free Courses', icon: Icons.school),
  TabItem(title: 'Premium Courses', icon: Icons.workspace_premium),
  TabItem(title: 'Free E-Books', icon: Icons.menu_book),
  TabItem(title: 'Premium E-Books', icon: Icons.library_books),
];
