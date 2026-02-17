import 'package:coders_adda_app/models/my_cource_model.dart';
import 'package:coders_adda_app/services/navigation_service.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_cource_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_course_player_page.dart';
import 'package:coders_adda_app/views/my_owened_pdf/my_pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCoursesPage extends StatelessWidget {
  final MyCoursesViewModel viewModel = MyCoursesViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'My Learning',
              style: TextStyle(fontSize: AppSizer.deviceSp20),
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: 'My Courses'),
                Tab(text: 'My PDFs'),
              ],
            ),
          ),
          body: Consumer<MyCoursesViewModel>(
            builder: (context, viewModel, child) {
              return TabBarView(
                children: [
                  _buildCoursesTab(context, viewModel.courses),
                  _buildPdfsTab(context, viewModel.pdfs),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesTab(BuildContext context, List<MyCourse> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Courses Purchased',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Explore our courses and start learning!',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to home page or courses page
                // You can implement this based on your navigation structure
              },
              child: Text('Browse Courses'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return GestureDetector(
          onTap: () {
            // Navigate to Course Player Page
            NavigationService.navigateTo(
              context,
              CoursePlayerPage(course: course),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
            elevation: 2,
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Thumbnail - Top
                  Container(
                    width: double.infinity,
                    height: AppSizer.deviceHeight25,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizer.deviceWidth2),
                        topRight: Radius.circular(AppSizer.deviceWidth2),
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
                        : Stack(
                            children: [
                              // Progress overlay on image
                              if (course.progress > 0)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: LinearProgressIndicator(
                                    value: course.progress,
                                    backgroundColor: Colors.black.withOpacity(
                                      0.3,
                                    ),
                                    color: course.progress == 1.0
                                        ? AppColors.successColor
                                        : AppColors.primaryColor,
                                    minHeight: AppSizer.deviceHeight0_5,
                                  ),
                                ),

                              // Play button overlay
                              if (course.progress == 0)
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      AppSizer.deviceWidth2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: AppSizer.deviceSp20,
                                    ),
                                  ),
                                ),

                              // Completed badge on image
                              if (course.progress == 1.0)
                                Positioned(
                                  top: AppSizer.deviceHeight1,
                                  right: AppSizer.deviceWidth2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizer.deviceWidth2,
                                      vertical: AppSizer.deviceHeight0_5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'COMPLETED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppSizer.deviceSp10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),

                  // Course Details - Below Image
                  Padding(
                    padding: EdgeInsets.all(AppSizer.deviceWidth4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Title
                        Text(
                          course.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizer.deviceSp16,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppSizer.deviceHeight1),

                        // Progress Information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Progress Percentage
                            Text(
                              '${(course.progress * 100).toInt()}% completed',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: AppSizer.deviceSp12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Progress Status
                            if (course.progress == 1.0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizer.deviceWidth2,
                                  vertical: AppSizer.deviceHeight0_5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.successColor,
                                      size: AppSizer.deviceSp14,
                                    ),
                                    SizedBox(width: AppSizer.deviceWidth1),
                                    Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: AppColors.successColor,
                                        fontSize: AppSizer.deviceSp12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: AppSizer.deviceHeight1),

                        // Continue Button - Full Width
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              NavigationService.navigateTo(
                                context,
                                CoursePlayerPage(course: course),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: course.progress == 1.0
                                  ? AppColors.successColor
                                  : AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  course.progress == 0.0
                                      ? Icons.play_arrow
                                      : course.progress == 1.0
                                      ? Icons.replay
                                      : Icons.play_arrow,
                                  size: AppSizer.deviceSp16,
                                ),
                                SizedBox(width: AppSizer.deviceWidth2),
                                Text(
                                  course.progress == 0.0
                                      ? 'Start Course'
                                      : course.progress == 1.0
                                      ? 'Watch Again'
                                      : 'Continue',
                                  style: TextStyle(
                                    fontSize: AppSizer.deviceSp16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
      },
    );
  }

  Widget _buildPdfsTab(BuildContext context, List<PdfItem> pdfs) {
    if (pdfs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No PDFs Available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      itemCount: pdfs.length,
      itemBuilder: (context, index) {
        final pdf = pdfs[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
          elevation: 1,
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(AppSizer.deviceWidth2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: AppSizer.deviceSp20,
              ),
            ),
            title: Text(
              pdf.title,
              style: TextStyle(fontSize: AppSizer.deviceSp16),
            ),
            subtitle: Text(
              pdf.size,
              style: TextStyle(fontSize: AppSizer.deviceSp14),
            ),
            trailing: FilledButton(
              onPressed: () {
                // Open PDF Viewer
                NavigationService.navigateTo(
                  context,
                  MyPdfViewerPage(pdf: pdf),
                );
              },
              child: Text(
                'View',
                style: TextStyle(fontSize: AppSizer.deviceSp14),
              ),
            ),
          ),
        );
      },
    );
  }
}
