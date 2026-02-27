import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_faq_tab_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_review_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_syllabus_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MyLearningCoursePlayer extends StatefulWidget {
  final String courseId;
  const MyLearningCoursePlayer({Key? key, required this.courseId}) : super(key: key);

  @override
  State<MyLearningCoursePlayer> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<MyLearningCoursePlayer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  bool _isDescriptionExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo(String url) {
    if (url.isEmpty) return;
    if (_videoController != null) {
      _videoController!.dispose();
    }
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
      }).catchError((e) {
        print("Video Error: $e");
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

          // Check if video URL changed and update video
          final videoUrl = viewModel.currentVideoUrl;
          if (videoUrl != null && videoUrl.isNotEmpty && 
              (_videoController == null || _videoController!.dataSource != videoUrl)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeVideo(videoUrl);
            });
          }

          final course = viewModel.course!;

          return Scaffold(
            appBar: AppBar(
              title: Text(course.title, style: TextStyle(fontSize: AppSizer.deviceSp18)),
            ),
            body: Column(
              children: [
                // Video Player Container
                Container(
                  width: double.infinity,
                  height: AppSizer.deviceHeight25,
                  color: Colors.black,
                  child: _videoController != null && _videoController!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            VideoProgressIndicator(
                              _videoController!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: AppColors.primaryColor,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            Center(
                              child: IconButton(
                                icon: Icon(
                                  _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: AppSizer.deviceSp48,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                
                // Video Info Section
                Container(
                  width: double.infinity,
                  color: AppColors.cardColor,
                  padding: EdgeInsets.all(AppSizer.deviceWidth4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              viewModel.isPlayingPromo ? "Course Preview (Promo)" : (viewModel.selectedLesson?.title ?? course.title),
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          if (course.promoVideoUrl.isNotEmpty && !viewModel.isPlayingPromo)
                            TextButton.icon(
                              onPressed: () => viewModel.playPromoVideo(),
                              icon: const Icon(Icons.play_circle_outline, size: 20),
                              label: const Text("Watch Promo"),
                              style: TextButton.styleFrom(foregroundColor: Colors.orange),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSizer.deviceHeight1),
                      
                      // Syllabus Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseSyllabusPage(viewModel: viewModel),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt, color: Colors.white),
                        label: const Text("View Course Curriculum / Syllabus", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: Size(double.infinity, AppSizer.deviceHeight5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      
                      SizedBox(height: AppSizer.deviceHeight2),
                      AnimatedCrossFade(
                        firstChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.description,
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
                              onTap: () => setState(() => _isDescriptionExpanded = true),
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
                              course.description,
                              style: TextStyle(
                                fontSize: AppSizer.deviceSp14,
                                color: AppColors.textColor,
                                height: 1.4,
                              ),
                            ),
                            if (course.whatYouWillLearn.isNotEmpty) ...[
                              SizedBox(height: AppSizer.deviceHeight1),
                              const Text('What you will learn:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...course.whatYouWillLearn.map((item) => Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('• $item'),
                              )),
                            ],
                            SizedBox(height: AppSizer.deviceHeight1),
                            GestureDetector(
                              onTap: () => setState(() => _isDescriptionExpanded = false),
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
                        crossFadeState: _isDescriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
                
                // Tab Bar
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
                    labelStyle: TextStyle(fontSize: AppSizer.deviceSp14, fontWeight: FontWeight.w600),
                    tabs: const [
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
                      FAQsTab(),
                      ReviewsTab(),
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
