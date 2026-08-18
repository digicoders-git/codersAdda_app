import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:coders_adda_app/utils/app_sizer/app_sizer.dart';
import 'package:coders_adda_app/services/api_client.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/veiw_model/my_learning_courses_play_viewmodel.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_faq_tab_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_review_page.dart';
import 'package:coders_adda_app/views/my_owened_courses/course_syllabus_page.dart';
import 'package:coders_adda_app/views/common/in_app_pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pod_player/pod_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
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
  StreamSubscription? _connectivitySubscription;
  String? _lastInitializedVideoUrl;
  String? _lastInitializedLessonId;
  bool _isDescriptionExpanded = false;
  bool _isVideoEnded = false;
  
  bool _showCustomControls = false;
  Timer? _hideControlsTimer;
  Timer? _progressTimer;
  String? _certificateUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are offline. Please turn on mobile data or Wi-Fi.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _tabController.dispose();
    _podController?.dispose();
    _hideControlsTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgressTimer(CoursePlayerViewModel viewModel) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updateProgress(viewModel);
    });
  }

  Future<void> _updateProgress(CoursePlayerViewModel viewModel) async {
    if (_podController == null || !_podController!.isInitialised || viewModel.isPlayingPromo || viewModel.selectedLesson == null) return;
    
    try {
      final value = _podController!.videoPlayerValue;
      if (value == null) return;
      
      final position = value.position;
      final duration = value.duration;
      if (duration == Duration.zero) return;

      final data = {
        'courseId': viewModel.course!.id,
        'topicId': viewModel.selectedTopicId ?? '',
        'lectureId': viewModel.selectedLesson!.id,
        'watchedSeconds': position.inSeconds,
        'durationSeconds': duration.inSeconds,
      };

      final apiClient = ApiClient();
      final response = await apiClient.post(ApiUrls.updateProgress, data);

      if (response['success'] == true && response['certificateIssued'] == true) {
        if (mounted) {
          setState(() {
            _certificateUrl = response['certificateUrl'];
          });
        }
      }
    } catch (e) {
      debugPrint('Progress update error: $e');
    }
  }

  void _onVideoStateChanged() {
    if (_podController == null || !_podController!.isInitialised) return;

    final isPlaying = _podController!.isVideoPlaying;
    
    // When video pauses, keep controls visible
    if (!isPlaying) {
      setState(() {
        _showCustomControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      // When video plays, start timer to hide controls
      _hideControlsTimer?.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showCustomControls = false);
      });
    }
  }

  void _showControlsTemporarily() {
    if (_showCustomControls) {
      // Tap when visible -> Hide instantly
      setState(() {
        _showCustomControls = false;
      });
      _hideControlsTimer?.cancel();
    } else {
      // Tap when hidden -> Show temporarily
      setState(() {
        _showCustomControls = true;
      });
      _hideControlsTimer?.cancel();
      
      // Only hide if video is playing
      if (_podController?.isVideoPlaying == true) {
        _hideControlsTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showCustomControls = false;
            });
          }
        });
      }
    }
  }

  Future<void> _initializeVideo(String url, String? viewModelLessonId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Cannot load video.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (url.isEmpty || (_lastInitializedVideoUrl == url && _lastInitializedLessonId == viewModelLessonId)) return;
    _lastInitializedVideoUrl = url;
    _lastInitializedLessonId = viewModelLessonId;

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
        if (mounted) {
          setState(() {});
          _podController?.addListener(_onVideoStateChanged);
        }
        
        _podController?.addListener(() {
          if (!mounted) return;
          final value = _podController?.videoPlayerValue;
          if (value != null && value.isInitialized) {
            bool ended = value.position.inMilliseconds >= value.duration.inMilliseconds - 500 && value.duration != Duration.zero;
            if (ended && !_isVideoEnded) {
              setState(() {
                _isVideoEnded = true;
              });
              
              final viewModel = Provider.of<CoursePlayerViewModel>(context, listen: false);
              _updateProgress(viewModel); // Final update on complete
              
              if (viewModel.hasNextLecture && !viewModel.isPlayingPromo) {
                viewModel.playNextLecture();
              }
            } else if (!ended && _isVideoEnded) {
              setState(() {
                _isVideoEnded = false;
              });
            }
          }
        });
      }).catchError((e) {
        debugPrint('PodPlayer Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video playback failed. Check your connection.'), backgroundColor: Colors.red),
          );
        }
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
          final lessonId = viewModel.selectedLesson?.id;
          
          if (videoUrl != null && videoUrl.isNotEmpty && 
             (_lastInitializedVideoUrl != videoUrl || _lastInitializedLessonId != lessonId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _initializeVideo(videoUrl, lessonId);
                if (!viewModel.isPlayingPromo) _startProgressTimer(viewModel);
              }
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
                          ? Listener(
                              onPointerDown: (_) => _showControlsTemporarily(),
                              child: Stack(
                                children: [
                                  PodVideoPlayer(
                                    controller: _podController!,
                                  ),
                                  if (!viewModel.isPlayingPromo)
                                    Positioned(
                                      top: 10,
                                      left: 0,
                                      right: 0,
                                      child: AnimatedOpacity(
                                        opacity: _showCustomControls ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (viewModel.hasPrevLecture)
                                              IconButton(
                                                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                                                onPressed: _showCustomControls ? () {
                                                  _hideControlsTimer?.cancel();
                                                  viewModel.playPrevLecture();
                                                } : null,
                                              )
                                            else
                                              const SizedBox(),
                                            if (viewModel.hasNextLecture)
                                              IconButton(
                                                icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                                                onPressed: _showCustomControls ? () {
                                                  _hideControlsTimer?.cancel();
                                                  viewModel.playNextLecture();
                                                } : null,
                                              )
                                            else
                                              const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
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
                              
                              // Certificate section
                              if (_certificateUrl != null && _certificateUrl!.isNotEmpty) ...[
                                SizedBox(height: AppSizer.deviceHeight2),
                                const Divider(),
                                SizedBox(height: AppSizer.deviceHeight1),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () async {
                                        if (_certificateUrl == null || _certificateUrl!.isEmpty) return;
                                        try {
                                          if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Downloading certificate...")),
                                              );
                                            }
                                            
                                            var response = await Dio().get(
                                              _certificateUrl!, 
                                              options: Options(responseType: ResponseType.bytes)
                                            );
                                            final result = await ImageGallerySaverPlus.saveImage(
                                              Uint8List.fromList(response.data),
                                              quality: 100,
                                              name: "CodersAdda_Certificate_${DateTime.now().millisecondsSinceEpoch}",
                                            );

                                            if (result['isSuccess'] == true) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Certificate saved to gallery!")),
                                                );
                                              }
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Failed to save certificate.")),
                                                );
                                              }
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Storage permission required.")),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error: $e")),
                                            );
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                                            ),
                                            const SizedBox(width: 16),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Course Completed!',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Download your Certificate',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.download_rounded, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                          labelPadding: EdgeInsets.zero,
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
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) _podController?.pause();
                                });
                              },
                            ),
                            CourseTestsTab(
                              courseId: widget.courseId,
                              onPlay: () {
                                _podController?.pause();
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) _podController?.pause();
                                });
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
