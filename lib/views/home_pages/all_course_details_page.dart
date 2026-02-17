import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/course_detail_viewmodel.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/course_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllCourseDetailPage extends StatelessWidget {
  final Course course;

  const AllCourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseDetailViewModel(course),
      child: Consumer<CourseDetailViewModel>(
        builder: (context, viewModel, child) {
          final currentCourse = viewModel.course ?? course;

          return Scaffold(
            body: viewModel.isLoading && viewModel.course?.curriculum.isEmpty == true
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(child: Text(viewModel.errorMessage!))
                    : CustomScrollView(
                        slivers: [
                          // Header with Course Image
                          SliverAppBar(
                            expandedHeight: AppSizer.deviceHeight30,
                            flexibleSpace: FlexibleSpaceBar(
                              background: _buildCourseHeaderImage(context, currentCourse),
                            ),
                            pinned: true,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {},
                              ),
                            ],
                          ),

                          // Course Content
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(AppSizer.deviceWidth4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Course Title and Price Tag
                                  _buildCourseTitleSection(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight2),
                                  
                                  // Instructor Info
                                  _buildInstructorSection(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // Course Description
                                  _buildCourseDescription(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // What You'll Learn
                                  if (currentCourse.whatYouWillLearn.isNotEmpty)
                                    _buildLearningOutcomes(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // Course Curriculum
                                  if (currentCourse.curriculum.isNotEmpty)
                                    _buildCourseCurriculum(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // FAQs Section
                                  if (currentCourse.faqs.isNotEmpty)
                                    _buildCourseFAQs(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // Reviews Section
                                  if (currentCourse.reviews.isNotEmpty)
                                    _buildCourseReviews(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
            
            // Fixed Bottom Action Button
            bottomNavigationBar: _buildBottomActionButton(context, currentCourse, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildCourseHeaderImage(BuildContext context, Course course) {
    return Stack(
      children: [
        // Course Image
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
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
                    size: AppSizer.deviceSp48,
                  ),
                )
              : null,
        ),
        
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        // Paid Tag
        if (!course.isFree)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar
            right: AppSizer.deviceWidth4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer.deviceWidth3,
                vertical: AppSizer.deviceHeight0_5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: AppSizer.deviceSp12),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(
                    'PAID',
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
    );
  }

  Widget _buildCourseTitleSection(Course course) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: TextStyle(
                  fontSize: AppSizer.deviceSp20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: AppSizer.deviceHeight1),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: AppSizer.deviceSp16),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text('${course.rating}', style: TextStyle(fontSize: AppSizer.deviceSp14)),
                  SizedBox(width: AppSizer.deviceWidth3),
                  Icon(Icons.people, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text('${course.totalStudents}', style: TextStyle(fontSize: AppSizer.deviceSp14)),
                  SizedBox(width: AppSizer.deviceWidth3),
                  Icon(Icons.schedule, color: AppColors.onSurfaceVariant, size: AppSizer.deviceSp16),
                  SizedBox(width: AppSizer.deviceWidth1),
                  Text(course.duration, style: TextStyle(fontSize: AppSizer.deviceSp14)),
                ],
              ),
            ],
          ),
        ),
        if (!course.isFree)
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth3, vertical: AppSizer.deviceHeight1),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppSizer.deviceWidth2),
            ),
            child: Column(
              children: [
                Text(
                  '₹${course.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text('one-time', style: TextStyle(fontSize: AppSizer.deviceSp10, color: Colors.white70)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInstructorSection(Course course) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSizer.deviceWidth3)),
      child: Row(
        children: [
          Container(
            width: AppSizer.deviceWidth12, height: AppSizer.deviceWidth12,
            decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                course.instructor.isNotEmpty ? course.instructor.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join() : 'IN',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp14),
              ),
            ),
          ),
          SizedBox(width: AppSizer.deviceWidth3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instructor', style: TextStyle(fontSize: AppSizer.deviceSp12, color: AppColors.onSurfaceVariant)),
                SizedBox(height: AppSizer.deviceHeight0_5),
                Text(course.instructor, style: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDescription(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About This Course', style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold)),
        SizedBox(height: AppSizer.deviceHeight1),
        Text(course.description, style: TextStyle(fontSize: AppSizer.deviceSp15, color: AppColors.onSurfaceVariant, height: 1.6)),
        SizedBox(height: AppSizer.deviceHeight2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('${course.totalLessons}', 'Lessons'),
            _buildStatItem(course.duration, 'Duration'),
            _buildStatItem(course.technology, 'Tech'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: AppSizer.deviceSp16, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
        SizedBox(height: AppSizer.deviceHeight0_5),
        Text(label, style: TextStyle(fontSize: AppSizer.deviceSp13, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildLearningOutcomes(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What You\'ll Learn', style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold)),
        SizedBox(height: AppSizer.deviceHeight2),
        Wrap(
          spacing: AppSizer.deviceWidth2,
          runSpacing: AppSizer.deviceHeight1,
          children: course.whatYouWillLearn.map((outcome) => Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth3, vertical: AppSizer.deviceHeight1),
            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.successColor, size: AppSizer.deviceSp14),
                SizedBox(width: AppSizer.deviceWidth1),
                Text(outcome, style: TextStyle(fontSize: AppSizer.deviceSp14)),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCourseCurriculum(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Course Curriculum', style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold)),
            Text('${course.totalLessons} lessons', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: AppSizer.deviceSp12)),
          ],
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        ...course.curriculum.map((module) => _buildCurriculumModule(module)).toList(),
      ],
    );
  }

  Widget _buildCurriculumModule(CourseModule module) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      decoration: BoxDecoration(border: Border.all(color: AppColors.outline), borderRadius: BorderRadius.circular(AppSizer.deviceWidth3)),
      child: ExpansionTile(
        title: Text(module.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppSizer.deviceSp14)),
        subtitle: Text('${module.lessonCount} lessons • ${module.duration}', style: TextStyle(fontSize: AppSizer.deviceSp12)),
        children: [
          const Divider(height: 1),
          ...module.lessons.map((lesson) => _buildLessonItem(lesson)).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonItem(CourseLesson lesson) {
    return ListTile(
      leading: Icon(lesson.isFree ? Icons.play_circle_outline : Icons.lock_outline, color: lesson.isFree ? AppColors.primaryColor : Colors.grey),
      title: Text(lesson.title, style: TextStyle(fontSize: AppSizer.deviceSp13)),
      subtitle: Text(lesson.duration, style: TextStyle(fontSize: AppSizer.deviceSp11)),
      trailing: lesson.isFree ? const Icon(Icons.play_circle_filled, color: AppColors.primaryColor) : const Icon(Icons.lock, size: 16),
      onTap: lesson.isFree ? () { /* Play lesson */ } : null,
    );
  }

  Widget _buildCourseFAQs(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequently Asked Questions', style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold)),
        SizedBox(height: AppSizer.deviceHeight2),
        ...course.faqs.map((faq) => Container(
          margin: EdgeInsets.only(bottom: AppSizer.deviceHeight1_5),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
            border: Border.all(color: AppColors.outline.withOpacity(0.5)),
          ),
          child: ExpansionTile(
            title: Text(faq.question, style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppSizer.deviceSp14)),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(AppSizer.deviceWidth4, 0, AppSizer.deviceWidth4, AppSizer.deviceHeight2),
                child: Text(faq.answer, style: TextStyle(fontSize: AppSizer.deviceSp13, color: AppColors.onSurfaceVariant, height: 1.5)),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildCourseReviews(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Student Reviews', style: TextStyle(fontSize: AppSizer.deviceSp18, fontWeight: FontWeight.bold)),
            Text('${course.reviews.length} reviews', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: AppSizer.deviceSp12)),
          ],
        ),
        SizedBox(height: AppSizer.deviceHeight2),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: course.reviews.length,
          itemBuilder: (context, index) {
            final review = course.reviews[index];
            return Container(
              margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
              padding: EdgeInsets.all(AppSizer.deviceWidth4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizer.deviceWidth3),
                border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(review.studentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizer.deviceSp14)),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          Icons.star,
                          size: AppSizer.deviceSp14,
                          color: i < review.rating ? Colors.amber : Colors.grey[300],
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Text(review.comment, style: TextStyle(fontSize: AppSizer.deviceSp13, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic)),
                  SizedBox(height: AppSizer.deviceHeight1),
                  Text(
                    '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                    style: TextStyle(fontSize: AppSizer.deviceSp10, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomActionButton(BuildContext context, Course course, CourseDetailViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(AppSizer.deviceWidth4),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: viewModel.isLoading 
              ? null 
              : () async {
                if (course.isFree) {
                  final success = await viewModel.enrollInFreeCourse();
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Succesfully enrolled in course!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(viewModel.errorMessage ?? 'Enrollment failed'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => CourseCheckoutPage(course: course))
                  );
                  if (context.mounted && result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Course purchased successfully!'), backgroundColor: Colors.green),
                    );
                    // Refresh course details to show enrolled state if needed
                    viewModel.fetchCourseDetails();
                  }
                }
              },
            style: FilledButton.styleFrom(
              backgroundColor: course.isFree ? AppColors.successColor : AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
            ),
            child: viewModel.isLoading && course.isFree
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  course.isFree ? 'ENROLL FOR FREE' : 'BUY NOW - ₹${course.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
          ),
        ),
      ),
    );
  }
}
