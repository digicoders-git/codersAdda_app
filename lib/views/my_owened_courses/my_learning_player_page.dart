import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_faq_tab_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_review_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_syllabus_page.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pod_player/pod_player.dart';
import 'course_quizzes_tab.dart';
import 'course_tests_tab.dart';

class MyLearningCoursePlayer extends StatefulWidget {
  final String courseId;
  const MyLearningCoursePlayer({Key? key, required this.courseId}) : super(key: key);

  @override
  State<MyLearningCoursePlayer> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<MyLearningCoursePlayer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PodPlayerController? _podController;
  String? _lastInitializedVideoUrl;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _podController?.dispose();
    super.dispose();
  }

  void _initializeVideo(String url) {
    if (url.isEmpty || _lastInitializedVideoUrl == url) return;
    _lastInitializedVideoUrl = url;

    _podController?.dispose();

    String trimmedUrl = url.trim();
    PlayVideoFrom source;

    debugPrint('Initializing Video with URL: $trimmedUrl');

    if (trimmedUrl.contains('youtube.com') || trimmedUrl.contains('youtu.be')) {
      source = PlayVideoFrom.youtube(trimmedUrl);
    } else if (trimmedUrl.contains('vimeo.com')) {
      source = PlayVideoFrom.vimeo(trimmedUrl);
    } else {
      source = PlayVideoFrom.network(trimmedUrl);
    }

    _podController = PodPlayerController(
      playVideoFrom: source,
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        isLooping: false,
        videoQualityPriority: [1080, 720, 360],
      ),
    )..initialise().then((_) {
        _podController?.play();
        if (mounted) setState(() {});
      }).catchError((e) {
        debugPrint('PodPlayer Error: $e');
      });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoursePlayerViewModel(widget.courseId),
      child: Consumer<CoursePlayerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (viewModel.errorMessage != null) {
            return Scaffold(body: Center(child: Text(viewModel.errorMessage!)));
          }
          if (viewModel.course == null) {
            return const Scaffold(body: Center(child: Text('Course not found')));
          }

          final videoUrl = viewModel.currentVideoUrl;
          if (videoUrl != null && videoUrl.isNotEmpty && _lastInitializedVideoUrl != videoUrl) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _initializeVideo(videoUrl);
            });
          }

          final course = viewModel.course!;

          return Scaffold(
            appBar: AppBar(
              title: Text(course.title, style: TextStyle(fontSize: AppSizer.deviceSp18)),
            ),
            body: Column(
              children: [
                // ── Video Player ──────────────────────────────
                Container(
                  width: double.infinity,
                  height: AppSizer.deviceHeight25,
                  color: Colors.black,
                  child: (viewModel.currentVideoUrl == null || viewModel.currentVideoUrl!.isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                              SizedBox(height: 8),
                              Text('No video available for this lesson', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        )
                      : _podController != null && _podController!.isInitialised
                          ? PodVideoPlayer(controller: _podController!)
                          : const Center(
                              child: CircularProgressIndicator(color: Colors.white)),
                ),

                // ── Rest of screen (scrollable info + fixed tabs) ──
                Expanded(
                  child: Column(
                    children: [
                      // Scrollable info section
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppSizer.deviceWidth4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current lesson title
                              Text(
                                viewModel.isPlayingPromo
                                    ? 'Course Preview (Promo)'
                                    : (viewModel.selectedLesson?.title ?? course.title),
                                style: TextStyle(
                                  fontSize: AppSizer.deviceSp18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              SizedBox(height: AppSizer.deviceHeight1),

                              // View Syllabus button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  _podController?.pause();
                                  // Extra pause in case it's still initializing
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    if (mounted) _podController?.pause();
                                  });
                                  
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseSyllabusPage(viewModel: viewModel),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.list_alt, color: Colors.white),
                                label: const Text('View Course Curriculum / Syllabus',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  minimumSize: Size(double.infinity, AppSizer.deviceHeight5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),

                              // Course Highlights badges
                              if (course.whatYouWillLearn.isNotEmpty) ...[
                                SizedBox(height: AppSizer.deviceHeight2),
                                Text(
                                  'Course Highlights',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizer.deviceSp16,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                SizedBox(height: AppSizer.deviceHeight1),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: course.whatYouWillLearn
                                      .map((item) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: AppColors.primaryColor.withOpacity(0.4),
                                                  width: 1.5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.stars_rounded,
                                                    size: 16,
                                                    color: AppColors.primaryColor),
                                                const SizedBox(width: 8),
                                                Text(
                                                  item,
                                                  style: TextStyle(
                                                    fontSize: AppSizer.deviceSp13,
                                                    color: AppColors.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],

                              SizedBox(height: AppSizer.deviceHeight1),
                              const Divider(),
                              SizedBox(height: AppSizer.deviceHeight1),

                              // Description with expand/collapse
                              AnimatedCrossFade(
                                firstChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.description,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp14,
                                        color: AppColors.textColor.withOpacity(0.8),
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight1),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _isDescriptionExpanded = true),
                                      child: Text(
                                        'Read full description',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp14,
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                secondChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.description,
                                      style: TextStyle(
                                        fontSize: AppSizer.deviceSp14,
                                        color: AppColors.textColor.withOpacity(0.8),
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: AppSizer.deviceHeight1),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _isDescriptionExpanded = false),
                                      child: Text(
                                        'Show less',
                                        style: TextStyle(
                                          fontSize: AppSizer.deviceSp14,
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
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
                            ],
                          ),
                        ),
                      ),

                      // ── TabBar (fixed at bottom) ──────────────
                      Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.outline)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primaryColor,
                          unselectedLabelColor: AppColors.onSurfaceVariant,
                          indicatorColor: AppColors.primaryColor,
                          indicatorWeight: 3,
                          labelStyle: TextStyle(
                              fontSize: AppSizer.deviceSp14,
                              fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: 'FAQs'),
                            Tab(text: 'Reviews'),
                            Tab(text: 'Quizzes'),
                            Tab(text: 'Tests'),
                          ],
                        ),
                      ),

                      // ── TabBarView (takes remaining space) ────
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            const FAQsTab(),
                            const ReviewsTab(),
                            CourseQuizzesTab(
                              courseId: widget.courseId,
                              onPlay: () {
                                _podController?.pause();
                              },
                            ),
                            CourseTestsTab(
                              courseId: widget.courseId,
                              onPlay: () {
                                _podController?.pause();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
