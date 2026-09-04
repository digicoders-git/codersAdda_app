import 'package:coders_adda_app/models/course_model.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/course_detail_viewmodel.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/course_purchase_page.dart';
import 'package:coders_adda_app/views/buy_new_courses_pages/purchase_success_modal.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/my_learning_player_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/lecture_video_player_page.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';
import 'package:coders_adda_app/veiw_model/wishlist_viewmodel.dart';
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Image.asset(
                'assets/images/mainLogo.png', 
                height: AppSizer.deviceHeight10,
                fit: BoxFit.contain,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Consumer<WishlistViewModel>(
                  builder: (context, wishlistVM, child) {
                    final isFav = wishlistVM.isFavorite(currentCourse.id);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : const Color(0xFF1E293B),
                      ),
                      onPressed: () => wishlistVM.toggleFavorite(currentCourse.id),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: viewModel.isLoading && viewModel.course?.curriculum.isEmpty == true
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(child: Text(viewModel.errorMessage!))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Header Card & Overlapping Instructor Card
                            _buildHeaderAndInstructor(context, currentCourse),
                            
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // 2. Quick Facts Row
                                  _buildQuickFactsCard(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // 3. Course Description
                                  _buildCourseDescription(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // 4. What You'll Learn
                                  if (currentCourse.whatYouWillLearn.isNotEmpty)
                                    _buildLearningOutcomes(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // 5. Course Curriculum
                                  if (currentCourse.curriculum.isNotEmpty)
                                    _buildCourseCurriculum(context, currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // 6. FAQs Section
                                  if (currentCourse.faqs.isNotEmpty)
                                    _buildCourseFAQs(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight3),
                                  
                                  // 7. Reviews Section
                                  if (currentCourse.reviews.isNotEmpty)
                                    _buildCourseReviews(currentCourse),
                                  
                                  SizedBox(height: AppSizer.deviceHeight4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
            
            // Fixed Bottom Action Button
            bottomNavigationBar: _buildBottomActionButton(context, currentCourse, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildHeaderAndInstructor(BuildContext context, Course course) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizer.deviceWidth4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A), // Dark blue badge
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.isFree ? 'FREE' : 'PREMIUM',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),
                    // Title
                    Text(
                      course.title,
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    SizedBox(height: AppSizer.deviceHeight1_5),
                    // Stats Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF97316), size: 16),
                            const SizedBox(width: 4),
                            Text(course.rating.toStringAsFixed(1), style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('(${course.reviews.length})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, color: Color(0xFF1E293B), size: 14),
                            const SizedBox(width: 4),
                            Text('${course.totalStudents} Students', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF1E293B), size: 14),
                            const SizedBox(width: 4),
                            Text(course.duration.isNotEmpty ? course.duration : '0h', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSizer.deviceWidth3),
              // Right Square Image
              Expanded(
                flex: 5,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF0F172A),
                      image: course.thumbnail.isNotEmpty ? DecorationImage(
                        image: NetworkImage(course.thumbnail),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizer.deviceHeight2),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (course.technology.isNotEmpty ? course.technology.split(',') : ['General']).map((tech) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tech.trim(), style: const TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
          
          SizedBox(height: AppSizer.deviceHeight3),
          
          // Instructor Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A), // Dark blue
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      course.instructor.isNotEmpty ? course.instructor.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join() : 'IN',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Instructor', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(course.instructor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      const Text('AI & ML Expert | 10+ Years Experience', style: TextStyle(fontSize: 11, color: Colors.grey)), 
                    ],
                  ),
                ),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Light gray bg
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF64748B), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFactsCard(Course course) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickFactItem(Icons.play_circle_outline, const Color(0xFF8B5CF6), '${course.totalLessons}', 'Lessons'),
          _buildQuickFactDivider(),
          _buildQuickFactItem(Icons.schedule, const Color(0xFF3B82F6), course.duration.isNotEmpty ? course.duration : '0h', 'Duration'),
          _buildQuickFactDivider(),
          _buildQuickFactItem(Icons.trending_up, const Color(0xFF10B981), 'Beginner to', 'Advanced'),
          _buildQuickFactDivider(),
          _buildQuickFactItem(Icons.workspace_premium_outlined, const Color(0xFFF59E0B), 'Certificate', 'Included'),
        ],
      ),
    );
  }

  Widget _buildQuickFactItem(IconData icon, Color iconColor, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuickFactDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildCourseDescription(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About This Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 12),
        Text(course.description, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // Read more action placeholder
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Read More', style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFFEA580C), size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningOutcomes(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What You\'ll Learn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: course.whatYouWillLearn.map((outcome) => Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A), // Dark blue
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(outcome, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              )).toList(),
            );
          }
        ),
      ],
    );
  }

  Widget _buildCourseCurriculum(BuildContext context, Course course) {
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
        ...course.curriculum
            .where((module) => module.isActive)
            .map((module) => _buildCurriculumModule(context, course, module))
            .toList(),
      ],
    );
  }

  Widget _buildCurriculumModule(BuildContext context, Course course, CourseModule module) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizer.deviceHeight2),
      decoration: BoxDecoration(border: Border.all(color: AppColors.outline), borderRadius: BorderRadius.circular(AppSizer.deviceWidth3)),
      child: ExpansionTile(
        title: Text(module.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppSizer.deviceSp14)),
        subtitle: Text('${module.lessonCount} lessons • ${module.duration}', style: TextStyle(fontSize: AppSizer.deviceSp12)),
        children: [
          const Divider(height: 1),
          ...module.lessons.map((lesson) => _buildLessonItem(context, course, module, lesson)).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, Course course, CourseModule module, CourseLesson lesson) {
    return ListTile(
      leading: Icon(lesson.isFree ? Icons.play_circle_outline : Icons.lock_outline, color: lesson.isFree ? AppColors.logoBlue : Colors.grey),
      title: Text(lesson.title, style: TextStyle(fontSize: AppSizer.deviceSp13)),
      subtitle: Text(lesson.duration, style: TextStyle(fontSize: AppSizer.deviceSp11)),
      trailing: lesson.isFree ? Icon(Icons.play_circle_filled, color: AppColors.logoBlue) : const Icon(Icons.lock, size: 16),
      onTap: () {
        if (lesson.isFree) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LectureVideoPlayerPage(
                lecture: CourseLecture(
                  id: lesson.id,
                  title: lesson.title,
                  description: '',
                  duration: lesson.duration,
                  srNo: 0,
                  privacy: 'public',
                  isActive: true,
                  video: LectureVideo(url: lesson.videoUrl, publicId: ''),
                  thumbnail: LectureVideo(url: lesson.thumbnailUrl ?? '', publicId: ''),
                  resource: LectureVideo(url: lesson.pdfUrl ?? '', publicId: ''),
                  courseName: course.title,
                  topicName: module.title,
                  isCompleted: false,
                ),
                courseId: course.id,
                topicId: module.id,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This lecture is locked. Please purchase the course to view it.'),
              backgroundColor: AppColors.logoOrange,
            ),
          );
        }
      },
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
                          color: i < review.rating ? AppColors.logoOrange : Colors.grey[300],
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
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final isEnrolled = profileVM.user?.purchaseCourseIds.contains(course.id) == true ||
                       profileVM.user?.subscriptionCourseIds.contains(course.id) == true;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSizer.deviceWidth4, AppSizer.deviceHeight2, AppSizer.deviceWidth4, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (!isEnrolled && !course.isFree) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${course.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const Text('one-time payment', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                SizedBox(width: AppSizer.deviceWidth4),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: isEnrolled 
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyLearningCoursePlayer(courseId: course.id)),
                        );
                      }
                    : (viewModel.isLoading 
                        ? null 
                        : () async {
                          if (course.isFree) {
                            final success = await viewModel.enrollInFreeCourse();
                            if (context.mounted) {
                              if (success) {
                                profileVM.fetchUserProfile();
                                PurchaseSuccessModal.show(
                                  context,
                                  title: course.title,
                                  itemType: 'course',
                                  onGoToMyLearning: () {
                                    final tabIndex = PurchaseSuccessModal.getTabIndexForItemType('course', true);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => MyLearningPage(initialTabIndex: tabIndex)),
                                      (route) => route.isFirst,
                                    );
                                  },
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
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => CourseCheckoutPage(course: course))
                            );
                          }
                        }),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), // Dark navy blue
                    padding: EdgeInsets.symmetric(vertical: AppSizer.deviceHeight1_5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: viewModel.isLoading && course.isFree && !isEnrolled
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isEnrolled 
                            ? 'START LEARNING' 
                            : (course.isFree ? 'ENROLL FOR FREE' : 'BUY NOW - ₹${course.price.toStringAsFixed(0)}'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
          if (!isEnrolled && !course.isFree) ...[
            SizedBox(height: AppSizer.deviceHeight2),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(children: [Icon(Icons.lock_outline, size: 12, color: Colors.grey), SizedBox(width: 4), Text('Secure Payment', style: TextStyle(fontSize: 10, color: Colors.grey))]),
                Text('|', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Row(children: [Icon(Icons.flash_on, size: 12, color: Colors.grey), SizedBox(width: 4), Text('Instant Access', style: TextStyle(fontSize: 10, color: Colors.grey))]),
                Text('|', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Row(children: [Icon(Icons.all_inclusive, size: 12, color: Colors.grey), SizedBox(width: 4), Text('Lifetime Access', style: TextStyle(fontSize: 10, color: Colors.grey))]),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
